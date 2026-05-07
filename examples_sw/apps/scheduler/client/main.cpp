/**
 * Scheduler client: drives the µShell coverage-aware vFPGA scheduler.
 *
 * Each "app" needs two HW modules (app_mapping); the scheduler picks tasks
 * whose required modules already overlap with currently-loaded vFPGAs to
 * minimise partial reconfigurations. Tasks live in three priority queues
 * with aging (queues bubble up after waiting >= 3 cycles). The HW_TEST
 * branch exercises real cThread LOCAL_TRANSFER ops; otherwise workers
 * sleep to simulate fixed task durations.
 */

#include "types.hpp"

#include <thread>
#include <future>
#include <math.h>
#include <unordered_map>
#include <random>
#include <cmath>

#include "worker_pool.hpp"
#define HW_TEST
// #define DEBUG



int n_regions = 4;
int def_policy = 0;
int def_tasks = 8;


std::atomic<bool> stalled(false);
void gotInt(int) {
    stalled.store(true);
}

std::mutex tasks_mutex;

struct Time {
    double cmpl;
    double turn;
    double wait;

    Time() : cmpl(0.), turn(0.), wait(0.) {}
    Time(double a, double b, double c) : cmpl(a), turn(b), wait(c) {}
};

struct TaskInfo {
    std::vector<uint32_t> oids;
    uint32_t priority;
    uint32_t region_idx;
    std::vector<uint32_t> coverage;
    uint32_t time;
    std::chrono::high_resolution_clock::time_point start_time;
    std::chrono::high_resolution_clock::time_point end_time;
    double response;
    double deadline;
};




std::vector<std::unique_ptr<cThread<std::any>>> cthread;
void* hMem[8];
sgEntry sg[8];

WorkerPool pool(8);

uint32_t reconfiguration_count = 0;

// 3 priority queues; tasks promote up after waiting too long.
std::vector<std::vector<TaskInfo>> tasks_arrays(3);
std::vector<TaskInfo> current_tasks;
std::vector<TaskInfo> tasks_scheduled;

std::vector<uint32_t> find_overlap(const std::vector<uint32_t>& arr1, const std::vector<uint32_t>& arr2) {
    std::vector<uint32_t> overlap;
    std::vector<uint32_t> arr2_copy = arr2;
    for (uint32_t num1 : arr1) {
        for (uint32_t num2 : arr2_copy) {
            if (num1 == num2) {
                overlap.push_back(num1);
                auto it = std::find(arr2_copy.begin(), arr2_copy.end(), num2);
                if (it != arr2_copy.end()) {
                    arr2_copy.erase(it);
                }
                break;
            }
        }
    }
    return overlap;
}

// Pick the task with the most module overlap with currently-loaded vFPGAs,
// minimising the number of partial reconfigurations needed.
int select_task(std::vector<TaskInfo>& tasks,
    const std::vector<uint32_t>& current_oid
    ) {
    std::cout << "in select_task" << std::endl;

    std::vector<int> coverage;

    for (auto& task : tasks) {
        std::vector<uint32_t> overlap = find_overlap(task.oids, current_oid);
        task.coverage = overlap;
        coverage.push_back(overlap.size());
#ifdef DEBUG
        std::cout << "task is: " << task.oids[0] << ", " << task.oids[1] << std::endl;
        std::cout << "overlap size is: " << overlap.size() << std::endl;
        for (auto& a : overlap) {
            std::cout << a << ", ";
        }
        std::cout << std::endl;
#endif
    }
#ifdef DEBUG
    std::cout << "Coverage size after push_back: " << coverage.size() << std::endl;
#endif

    if (!coverage.empty()) {
        int max_value = coverage[0];
        int max_index = 0;

        for (int i = 1; i < coverage.size(); ++i) {
            if (coverage[i] > max_value) {
                max_value = coverage[i];
                max_index = i;
            }
        }

        return max_index;
    }
    else {
        std::cout << "coverage array is 0" << std::endl;
        return -1;
    }
}


int32_t schedule_vfpga(TaskInfo& task, uint32_t n_regions, bool new_task, uint32_t policy) {

    std::vector<bool> region_used(n_regions, false);
    TaskInfo choosen_task;
    if (new_task)
        tasks_arrays[task.priority].push_back(task);

    uint8_t array_index = 0;
    std::vector<TaskInfo> tasks = tasks_arrays[0];

    for (auto& task_array : tasks_arrays) {
        if (task_array.size()) {
            tasks = task_array;
            break;
        }
        array_index++;
    }

    std::cout << "priority level " << static_cast<int>(array_index) << std::endl;
    std::cout << "tasks waiting to schedule" << std::endl;

    for (int i = 0; i < tasks.size(); ++i) {
        std::cout << tasks[i].oids[0] << ", " << tasks[i].oids[1] << ". time: " << tasks[i].time << std::endl;
    }

    std::vector<uint32_t> current_oid;
    std::vector<uint32_t> empty_vFPGA;
    std::vector<uint32_t> empty_vFPGA_index;

    for (int i = 0; i < current_tasks.size(); ++i) {
        current_oid.push_back(current_tasks[i].oids[0]);
    }

    std::cout << "empty vfpga" << std::endl;

    for (int i = 0; i < current_tasks.size(); ++i) {
        if (current_tasks[i].oids[0] == 0 || pool.is_busy(i) == false) {
            empty_vFPGA.push_back(current_tasks[i].oids[0]);
            empty_vFPGA_index.push_back(i);
            std::cout << "free vFPGA " << i << ", module " << current_tasks[i].oids[0] << std::endl;
        }
    }

    int next = 0;

    if (policy == 1) {
        next = select_task(tasks, empty_vFPGA);
    }


    int scheduled = 1;
    choosen_task = tasks[next];

    if (choosen_task.coverage.size() + empty_vFPGA.size() < choosen_task.oids.size()) {
        next = -1;
        std::cout << "vFPGA not enough" << std::endl;
    }

    if (next != -1) {
        std::vector<uint32_t> oids_no_overlap;

        std::cout << "selected task ";
        for (int i = 0; i < choosen_task.oids.size(); i++) {
            std::cout << choosen_task.oids[i] << ", ";
        }
        std::cout << std::endl;

        oids_no_overlap = choosen_task.oids;

        for (auto& e : choosen_task.coverage) {
            for (int i = 0; i < oids_no_overlap.size(); i++) {
                if (oids_no_overlap[i] == e) {
                    oids_no_overlap[i] = 0;
                    break;
                }
            }
        }
        oids_no_overlap.erase(std::remove(oids_no_overlap.begin(), oids_no_overlap.end(), 0), oids_no_overlap.end());

#ifdef DEBUG
        std::cout << "non overlap module ";
        for (auto& e : oids_no_overlap) {
            std::cout << e << ", ";
        }
        std::cout << std::endl;
#endif

        // Each scheduled task spawns a worker that fakes (or runs HW) for ~80ms;
        // reconfigure=1 adds a 34ms partial-reconfiguration delay on top.
        auto create_task = [](int id, TaskInfo task, std::vector<TaskInfo>& tasks, std::mutex& tasks_mutex, int reconfigure) {
            return [id, task, &tasks, &tasks_mutex, reconfigure] mutable {
                std::cout << "****" << id << "****\n";
                std::cout << "vFPGA " << id << " starting task\n";
                if (reconfigure) {
                    std::this_thread::sleep_for(std::chrono::milliseconds(34));
                }
#ifdef HW_TEST
                for(int i = 0; i < 32; i++) {
                    cthread[id]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[id], {true, true, false});
                    while(cthread[id]->checkCompleted(CoyoteOper::LOCAL_WRITE) != 1)
                        if(stalled.load()) throw std::runtime_error("Stalled, SIGINT caught");
                }
#else
                std::this_thread::sleep_for(std::chrono::milliseconds(80));
#endif
                {
                    std::lock_guard<std::mutex> lock(tasks_mutex);
                    try {
                        task.end_time = std::chrono::high_resolution_clock::now();
                        tasks.push_back(task);
                    } catch (const std::bad_alloc& e) {
                        std::cerr << "Allocation failed: " << e.what() << std::endl;
                    }
                }
                std::cout << "Worker " << id << " completed task\n";
            };
        };

        // Reuse vFPGAs whose currently-loaded module matches one in the
        // chosen task's coverage list — no reconfiguration needed.
        for (int i = 0; i < choosen_task.coverage.size(); ++i) {
            int found = -1;
            for (int j = 0; j < empty_vFPGA_index.size(); j++) {
                if (current_tasks[empty_vFPGA_index[j]].oids[0] == choosen_task.coverage[i] && pool.is_busy(empty_vFPGA_index[j]) == false) {
                    found = empty_vFPGA_index[j];
                    std::cout << "reusing vFPGA " << found << ", module: " << choosen_task.coverage[i] << std::endl;
                    TaskInfo task_copy = choosen_task;
                    pool.assign_task(found, create_task(found, task_copy, tasks_scheduled, tasks_mutex, 0));
                    empty_vFPGA_index.erase(empty_vFPGA_index.begin() + j);

                    break;
                }
            }
        }


        // Modules not already loaded need a partial reconfiguration on a free slot.
        for (int i = 0; i < oids_no_overlap.size(); ++i) {
            if (empty_vFPGA_index.size() > 0) {
                std::cout << "need to reconfigure" << std::endl;
                std::cout << "vFPGA index " << empty_vFPGA_index[0] << ", module: " << oids_no_overlap[i] << std::endl;
                current_tasks[empty_vFPGA_index[0]].oids[0] = oids_no_overlap[i];
                TaskInfo task_copy = choosen_task;
                pool.assign_task(empty_vFPGA_index[0], create_task(empty_vFPGA_index[0], task_copy, tasks_scheduled, tasks_mutex, 1));
                empty_vFPGA_index.erase(empty_vFPGA_index.begin() + 0);
                reconfiguration_count += 1;
            }
        }
        if (scheduled) {
            tasks_arrays[array_index].erase(tasks_arrays[array_index].begin() + next);
            std::cout << "task found " << next << std::endl;
        }
    }
    else {
        scheduled = 0;
        std::cout << "no task found " << next << std::endl;
    }

#ifdef DEBUG
    std::cout << "current status: " << std::endl;
    for (int i = 0; i < current_tasks.size(); i++) {
        std::cout << "vFPGA " << i << ": " << current_tasks[i].oids[0] << std::endl;
    }
#endif

    for (auto& task_array : tasks_arrays) {
        if (task_array.size()) {
            for (auto& task : task_array) {
                task.time ++;
            }
        }
    }

    // Aging: tasks waiting >= 3 cycles bubble up one priority level.
    if (policy == 1) {
        for (int i = 1; i < 3; i++) {
            auto& current_queue = tasks_arrays[i];
            auto& target_queue = tasks_arrays[i - 1];

            for (auto it = current_queue.begin(); it != current_queue.end(); ) {
                if (it->time >= 3) {
                    it->time = 0;
                    target_queue.push_back(*it);
                    it = current_queue.erase(it);
                    std::cout << "promoting task" << std::endl;
                } else {
                    ++it;
                }
            }
        }
    }

    if (scheduled) {
        std::cout << "task scheduled" << std::endl;
        return next;
    }
    else {
        std::cout << "no task scheduled" << std::endl;
        return -1;

    }
}


int main(int argc, char* argv[])
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    uint32_t cs_dev = def_dev;
    uint32_t policy = def_policy;
    uint32_t n_tasks = def_tasks;
    uint32_t n_apps = total_apps;
    uint32_t n_tuples = 8 * 1024;
    uint32_t n_features = 5;
    std::string task_order = "rng";
    uint32_t task_order_mode = 2;

    po::options_description desc("Options");
    desc.add_options()
        ("help,h", "Show this help message")
        ("device,d", po::value<uint32_t>(&cs_dev)->default_value(cs_dev), "Target device")
        ("policy,p", po::value<uint32_t>(&policy)->default_value(policy), "Policy")
        ("tasks,t", po::value<uint32_t>(&n_tasks)->default_value(n_tasks), "Number of tasks total")
        ("taskorder,o", po::value<std::string>(&task_order)->default_value(task_order), "Task ordering mode (seq|grp|rng)")
        ("nconfig,n", po::value<uint32_t>(&n_apps)->default_value(n_apps), "Number of HyperLogLog variations to use")
        ("tuples", po::value<uint32_t>(&n_tuples)->default_value(n_tuples), "Number of tuples")
        ("features", po::value<uint32_t>(&n_features)->default_value(n_features), "Number of features")
    ;

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    if (vm.count("help")) {
        std::cout << "Usage: options_description [options]\n";
        std::cout << desc;
        return 0;
    }

    if (vm.count("taskorder")) {
        if (task_order == "seq") task_order_mode = 0;
        else if (task_order == "grp") task_order_mode = 1;
        else if (task_order == "rng") task_order_mode = 2;
        else {
            std::cout << "Invalid ordering mode. Available sequential (seq), grouped (grp) or random (rng)" << std::endl;
            task_order = "seq";
            task_order_mode = 0;
        }
    }

    if (n_apps <= 0 || n_apps > total_apps) {
        std::cout << "Invalid configurations count. Max: " << total_apps << std::endl;
        return 1;
    }

    PR_HEADER("PARAMS");
    std::cout << "Device:             " << cs_dev << std::endl;
    std::cout << "Number of regions:  " << n_regions << std::endl;
    std::cout << "Number of tasks:    " << n_tasks << std::endl;
    std::cout << "Task order mode:    " << task_order << std::endl;
    if (policy == 1)
        std::cout << "Policy:             " << "Custom" << std::endl;
    else
        std::cout << "Policy:             " << "FIFO" << std::endl;
    std::cout << std::endl;


#ifdef HW_TEST
    bool mapped = true;
    bool huge = true;
    bool stream = 1;
    uint32_t max_size = 16 * 1024 * 1024;
    uint32_t curr_size = 16 * 1024 * 1024;

    for (int i = 0; i < n_regions; i++) {
        cthread.emplace_back(new cThread<std::any>(i, getpid(), cs_dev));
        hMem[i] = mapped ? (cthread[i]->getMem({huge ? CoyoteAlloc::HPF : CoyoteAlloc::REG, max_size}))
                         : (huge ? (mmap(NULL, max_size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0))
                                 : (malloc(max_size)));
    }


    for(int i = 0; i < n_regions; i++) {
        memset(&sg[i], 0, sizeof(localSg));
        sg[i].local.src_addr = hMem[i]; sg[i].local.src_len = curr_size; sg[i].local.src_stream = stream;
        sg[i].local.dst_addr = hMem[i]; sg[i].local.dst_len = curr_size; sg[i].local.dst_stream = stream;
    }

    for (int j = 0; j < n_regions; j++) {
        for (int i = 0; i < max_size / 8; i++) {
            ((uint32_t *)hMem[j])[i] = 0;
        }
    }

    std::unordered_map<int, std::vector<uint32_t>> vFPGA_mapping = {
        {1, {0, 5}},
        {2, {1, 3}},
        {3, {2, 6}},
        {4, {4, 7}}
    };

#endif

    // App ID -> required module IDs. Each app needs two modules to run.
    std::unordered_map<int, std::vector<uint32_t>> app_mapping = {
        {1, {1, 2}},
        {2, {3, 2}},
        {3, {4, 1}}
    };

    int32_t taskOID[n_tasks];
    if (n_tasks == 0) {
        DBG3("Nothing to run.");
        std::cout << "See --help to view available options." << std::endl;
        exit(EXIT_SUCCESS);
    }

    std::vector<TaskInfo> tasks_to_schedule;
    srand(n_tasks * 7 + n_features);

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> distr(20, 50);

    for (int32_t i = 0; i < n_tasks; ++i) {
        if (task_order_mode == 0) {
            taskOID[i] = (i % n_apps) + 1;
        }
        else if (task_order_mode == 1) {
            taskOID[i] = (i / n_apps) + 1;
        }
        else if (task_order_mode == 2) {
            taskOID[i] = (rand() % n_apps) + 1;
            TaskInfo task;
            std::cout << "taskOID[i] is " << taskOID[i] << std::endl;
            task.oids = app_mapping.at(taskOID[i]);
            task.priority = (rand() % 3);
            task.time = 0;
            task.deadline = (40 + 80) * (100 + distr(gen)) / 100 * (task.priority + 1);
            tasks_to_schedule.push_back(task);
            std::cout << "input is " << task.oids[0] << ", " << task.oids[1] << std::endl;
            std::cout << "task priority: " << task.priority << std::endl;
            std::cout << "task deadline: " << task.deadline << std::endl;
        }
        else {
            DBG3("Invalid ordering mode.");
            exit(EXIT_FAILURE);
        }
    }

    for (int i = 0; i < n_regions; i++) {
        TaskInfo task;
        task.oids.push_back(0);
        task.time = 0;
        current_tasks.push_back(task);
    }

    auto sched_begin = std::chrono::high_resolution_clock::now();
    int32_t result = 0;
    uint32_t cycle = 0;

#ifdef HW_TEST
    // Warm up vFPGA 0 with 32 transfers before the scheduling experiment, so
    // first-iteration outliers don't pollute the latency measurements below.
    for(int i = 0; i < 32; i++) {
        cthread[0]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[0], {true, true, false});
        while(cthread[0]->checkCompleted(CoyoteOper::LOCAL_WRITE) != 1)
            if(stalled.load()) throw std::runtime_error("Stalled, SIGINT caught");
    }

    auto sched_middle = std::chrono::high_resolution_clock::now();
    double duration_middle;
    duration_middle = (std::chrono::duration_cast<std::chrono::microseconds>(sched_middle - sched_begin).count() / 1000.0);
    std::cout<< "Experiment current (ms): " << duration_middle << std::endl;
#endif

    sched_begin = std::chrono::high_resolution_clock::now();
    int limit = 0;
    while (tasks_to_schedule.size() > 0) {
        std::cout << "---------------------------------------------------------------" << std::endl;
        std::cout << "tasks_to_schedule size is " << tasks_to_schedule.size() << std::endl;
        std::cout << "input is " << tasks_to_schedule[0].oids[0] << ", " << tasks_to_schedule[0].oids[1] << std::endl;

        cycle++;
        tasks_to_schedule[0].start_time = std::chrono::high_resolution_clock::now();
        std::cout << "starting time: " << (std::chrono::duration_cast<std::chrono::microseconds>(tasks_to_schedule[0].start_time - sched_begin).count() / 1000.0) << std::endl;

        result = schedule_vfpga(tasks_to_schedule[0], n_regions, true, policy);

        tasks_to_schedule.erase(tasks_to_schedule.begin() + 0);
        if (result >= 0) {
            std::cout << "scheduling some task " << result << std::endl;
        }
#ifdef DEBUG
        sched_middle = std::chrono::high_resolution_clock::now();
        duration_middle = (std::chrono::duration_cast<std::chrono::microseconds>(sched_middle - sched_begin).count() / 1000.0);
        std::cout<< "Experiment current (ms): " << duration_middle << std::endl;
#endif
        std::this_thread::sleep_for(std::chrono::milliseconds(20));
    }

    std::cout << "schedule finished. Cycle: " << cycle << std::endl;

    int remain_task = 0;
    int limit_2 = 0;
    for (int i = 0; i < tasks_arrays.size(); ++i) {
        remain_task += tasks_arrays[i].size();
    }

    // Drain any tasks left in the priority queues after the input stream ends.
    TaskInfo task_empty;
    while (remain_task > 0) {
        std::cout << "===============================================================" << std::endl;
        std::cout << "scheduling remain tasks " << remain_task << std::endl;
        cycle++;

        result = schedule_vfpga(task_empty, n_regions, false, policy);

        if (result >= 0) {
            std::cout << "scheduling some task " << result << std::endl;
        }
        remain_task = 0;
        for (int i = 0; i < tasks_arrays.size(); ++i) {
            remain_task += tasks_arrays[i].size();
        }
#ifdef DEBUG
        sched_middle = std::chrono::high_resolution_clock::now();
        duration_middle = 0.0;
        duration_middle = (std::chrono::duration_cast<std::chrono::microseconds>(sched_middle - sched_begin).count() / 1000.0);
        std::cout<< "Experiment current (ms): " << duration_middle << std::endl;

#endif
        std::this_thread::sleep_for(std::chrono::milliseconds(20));
        std::cout << "in schedule remain end" << std::endl;
    }

    std::cout << "schedule remain finished" << std::endl;

    bool all_completed = true;

    while (true) {
        all_completed = true;
        for (int i = 0; i < 4; ++i) {
            if (pool.is_busy(i)) {
                all_completed = false;
            }
        }
        if (all_completed) break;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }


    std::cout << "All task done." << std::endl;

    double durationMs = 0.0;
    double durationMs_final = 0.0;

    auto sched_end = std::chrono::high_resolution_clock::now();
    durationMs_final = (std::chrono::duration_cast<std::chrono::microseconds>(sched_end - sched_begin).count() / 1000.0);

    std::vector<double> response_time;
    int deadline_miss_count = 0;
    for (auto& task : tasks_scheduled) {
        std::cout << "--------------------------------------------------" << std::endl;
        std::cout << "task components: " << task.oids[0] << ", " << task.oids[1] << std::endl;
        std::cout << "starting time: " << (std::chrono::duration_cast<std::chrono::microseconds>(task.start_time - sched_begin).count() / 1000.0) << std::endl;
        std::cout << "end time: " << (std::chrono::duration_cast<std::chrono::microseconds>(task.end_time - sched_begin).count() / 1000.0) << std::endl;
        durationMs = (std::chrono::duration_cast<std::chrono::microseconds>(task.end_time - task.start_time).count() / 1000.0);
        response_time.push_back(durationMs);
        std::cout << "duration: " << durationMs << " ms" << std::endl;
        if (task.deadline < durationMs) {
            deadline_miss_count ++;
        }
    }


    double sum = std::accumulate(response_time.begin(), response_time.end(), 0.0);
    double average = sum / response_time.size();

    std::sort(response_time.begin(), response_time.end(), std::greater<double>());

    std::cout << "--------------------------------------------------" << std::endl;

    std::cout << "Sorted (largest to smallest): ";
    for (const double &time : response_time) {
        std::cout << time << " ";
    }
    std::cout << std::endl;

    std::cout << "Experiment finished duration (ms): " << durationMs_final << std::endl;

    std::cout << "Reconfiguration count: " << reconfiguration_count << std::endl;

    std::cout << "Average response time: " << average << std::endl;

    std::cout << "Response time (95%): " << response_time[static_cast<int>(std::ceil(n_tasks/20))] << std::endl;

    std::cout << "Deadline misses: " << deadline_miss_count << std::endl;

    std::cout << "--------------------------------------------------" << std::endl;

    std::cout << durationMs_final << std::endl;

    std::cout << reconfiguration_count << std::endl;

    std::cout << average << std::endl;

    std::cout << response_time[static_cast<int>(std::ceil(n_tasks/20))] << std::endl;

    std::cout << deadline_miss_count << std::endl;

    std::cout << "--------------------------------------------------" << std::endl;

    return (EXIT_SUCCESS);
}
