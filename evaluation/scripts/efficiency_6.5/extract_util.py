import os
import sys
import csv


def get_data(total, entry, line):
    # print(line)
    entry = [entry[0], line[5], round(float(line[5])/total[1]*100, 1),
                line[9], round(float(line[9])/total[3]*100, 1),
                float(line[10])+float(line[11])/2, round((float(line[10])+float(line[11])/2)/total[5]*100, 1),
                line[12], round(float(line[12])/total[7]*100, 1)]
    return entry

# def extract_util(coyote_path, ushell_path):
def extract_util(coyote_path, ushell_path, inter_4_path, inter_6_path, inter_8_path):
    result_table = []
    header = ["", "LUTs", "[%]", "Flips-Flops", "[%]", "BRAM", "[%]", "URAM", "[%]"]
    total = ["U280", 1303680, 100.0, 2607360, 100.0, 2016, 100.0, 960, 100.0]
    result_table.append(header)
    result_table.append(total)

    with open(coyote_path, "r") as f:
        reader = csv.reader(f, delimiter="|")
        for i, line in enumerate(reader):
            entry = []
            if len(line) < 5:
                continue
            for j in range(len(line)):
                line[j] = line[j].strip()
            if line[1] == "cyt_top":
                entry = ["Coyote"]
                entry = get_data(total, entry, line)
                result_table.append(entry)
                break

    with open(ushell_path, "r") as f:
        reader = csv.reader(f, delimiter="|")
        ceu_entry = ["CEU", 0, 0, 0, 0, 0, 0, 0, 0]
        # mmu_entry = ["MMU ", 0, 0, 0, 0, 0, 0]
        scheduler_entry = ["Scheduler", 0, 0, 0, 0, 0, 0, 0, 0]
        vio_entry = ["Virtual IO", 0, 0, 0, 0, 0, 0, 0, 0]

        for i, line in enumerate(reader):
            entry = []
            if len(line) < 5:
                continue
            for j in range(len(line)):
                line[j] = line[j].strip()
            # print(line)
            if line[1] == "cyt_top":
                entry = ["uShell"]
                entry = get_data(total, entry, line)
                result_table.append(entry)
            # elif line[1] == "inst_dtu_top_0" or line[1] == "inst_dtu_top_1" or line[2] == "inst_dtu_top_2":
            elif line[1] == "inst_memory_gateway" or line[1] == "inst_gate_recv" or line[2] == "inst_gate_send":
                ceu_entry[1] += float(line[5])
                ceu_entry[3] += float(line[9])
                ceu_entry[5] += float(line[10])+float(line[11])/2
                ceu_entry[7] +=float(line[12])
            elif line[1] == "inst_interconnect":
                entry = ["Inter 3"]
                entry = get_data(total, entry, line)
                result_table.append(entry)
            elif line[1] == "xdma_0":
                entry = ["PCIe DMA (xDMA)"]
                entry = get_data(total, entry, line)
                result_table.append(entry)
    #         elif line[2] == "cdma__parameterized0" or line[2] == "cdma":
    #             cdma_entry[1] += float(line[3])
    #             cdma_entry[3] += float(line[7])
    #             cdma_entry[5] += float(line[8])+float(line[9])/2
            elif line[1] == "inst_mmu_top":
                entry = ["MMU"]
                entry = get_data(total, entry, line)
                entry[1:] = [round(float(x) / 3.0, 1) for x in entry[1:]]
                result_table.append(entry)
    #         elif (line[1] == "inst_hdma_arb_rd" and line[2] == "tlb_arbiter") or line[2] == "tlb_arbiter__parameterized0":
    #             scheduler_entry[1] += float(line[3])
    #             scheduler_entry[3] += float(line[7])
    #             scheduler_entry[5] += float(line[8])+float(line[9])/2
    #         elif line[1] == "inst_user_wrapper_0":
    #             vio_entry[1] += float(line[3])
    #             vio_entry[3] += float(line[7])
    #             vio_entry[5] += float(line[8])+float(line[9])/2
    #         elif line[1] == "inst_reg_direct":
    #             vio_entry[1] -= float(line[3])
    #             vio_entry[3] -= float(line[7])
    #             vio_entry[5] -= float(line[8])+float(line[9])/2


    ceu_entry[1] = round(ceu_entry[1]/3, 1)
    ceu_entry[2] = round(float(ceu_entry[1])/total[1]*100, 1)
    ceu_entry[3] = round(ceu_entry[3]/3, 1)
    ceu_entry[4] = round(float(ceu_entry[3])/total[3]*100, 1)
    ceu_entry[5] = round(ceu_entry[5]/3, 1)
    ceu_entry[6] = round(float(ceu_entry[5])/total[5]*100, 1)
    ceu_entry[7] = round(ceu_entry[7]/3, 1)
    ceu_entry[8] = round(float(ceu_entry[7])/total[7]*100, 1)

    # mmu_entry[2] = round(float(cdma_entry[1])/total[1]*100, 1)
    # mmu_entry[4] = round(float(cdma_entry[3])/total[3]*100, 1)
    # mmu_entry[6] = round(float(cdma_entry[5])/total[5]*100, 1)


    # vio_entry[2] = round(float(vio_entry[1])/total[1]*100, 1)
    # vio_entry[4] = round(float(vio_entry[3])/total[3]*100, 1)
    # vio_entry[6] = round(float(vio_entry[5])/total[5]*100, 1)

    with open(inter_4_path, "r") as f:
        reader = csv.reader(f, delimiter="|")

        for i, line in enumerate(reader):
            entry = []
            if len(line) < 5:
                continue
            for j in range(len(line)):
                line[j] = line[j].strip()
            # print(line)
            if line[1] == "inst_interconnect":
                entry = ["Inter 4"]
                entry = get_data(total, entry, line)
                result_table.append(entry)

    with open(inter_6_path, "r") as f:
        reader = csv.reader(f, delimiter="|")

        for i, line in enumerate(reader):
            entry = []
            if len(line) < 5:
                continue
            for j in range(len(line)):
                line[j] = line[j].strip()
            # print(line)
            if line[1] == "inst_interconnect":
                entry = ["Inter 6"]
                entry = get_data(total, entry, line)
                result_table.append(entry)

    with open(inter_8_path, "r") as f:
        reader = csv.reader(f, delimiter="|")

        for i, line in enumerate(reader):
            entry = []
            if len(line) < 5:
                continue
            for j in range(len(line)):
                line[j] = line[j].strip()
            # print(line)
            if line[1] == "inst_interconnect":
                entry = ["Inter 8"]
                entry = get_data(total, entry, line)
                result_table.append(entry)

    result_table.append(ceu_entry)
    # result_table.append(cdma_entry)
    # result_table.append(scheduler_entry)
    # result_table.append(vio_entry)

    for i in result_table:
        print(i)


# Per-module footprints from the resource_usage build (7 modules on 7 vFPGAs
# in a single shell). Each row pulls the module-proper instance from inside
# its inst_user_c0_<i> wrapper, skipping the shell glue (skid registers,
# host_mux, debug bridge, AXI register slices, queue arbiters, credits).
# Instance names come from each module's apps/modules/<m>/vfpga_top.svh and
# the CMake load_apps order in baseline examples_hw/CMakeLists.txt.
MODULES = [
    ("FFT",      "inst_fft"),
    ("Quantize", "inst_quant"),
    ("RLE",      "inst_rle"),
    ("SHA-256",  "inst_sha256"),
    ("RSA",      "inst_rsa_c0_4"),
    ("AES-CTR",  "inst_aes"),
    ("SVM",      "inst_svm"),
]


def extract_modules(resource_usage_path="../../data/efficiency/module_resource_usage.csv"):
    """Per-module utilization from the 7-vFPGA resource_usage build.

    Reads the raw Vivado hierarchical report (default:
    ../data/module_resource_usage.csv, sibling to the util_*.csv files
    that extract_util() consumes). Emits the same wide-table layout —
    header + U280 totals + one row per module, columns
    [name, LUTs, %, FFs, %, BRAM, %, URAM, %] — so it composes with
    the shell breakdown printed by extract_util().
    """
    result_table = []
    header = ["", "LUTs", "[%]", "Flips-Flops", "[%]", "BRAM", "[%]", "URAM", "[%]"]
    total = ["U280", 1303680, 100.0, 2607360, 100.0, 2016, 100.0, 960, 100.0]
    result_table.append(header)
    result_table.append(total)

    # Pre-resolve which line in the report belongs to each module instance.
    # Vivado pads Instance with leading spaces for hierarchy depth, so we
    # match on the trimmed cell to keep the right user_c0_<i> child and
    # avoid nested look-alikes (e.g. there's a deeper inst_aes inside aes_top).
    wanted = {inst: name for name, inst in MODULES}
    seen = set()

    with open(resource_usage_path, "r") as f:
        reader = csv.reader(f, delimiter="|")
        for line in reader:
            if len(line) < 13:
                continue
            for j in range(len(line)):
                line[j] = line[j].strip()
            inst = line[1]
            if inst in wanted and inst not in seen:
                entry = [wanted[inst]]
                entry = get_data(total, entry, line)
                result_table.append(entry)
                seen.add(inst)

    for name, inst in MODULES:
        if inst not in seen:
            print(f"WARN: instance {inst} ({name}) not found in {resource_usage_path}",
                  file=sys.stderr)

    for i in result_table:
        print(i)


if __name__ == "__main__":
    # if len(sys.argv) != 3:
    #     print("Usage: python3 extract_util.py <path_to_util_coyote.csv> <path_to_util_ushell.csv>")
    #     print(sys.argv)
    #     sys.exit(1)
    # extract_util(sys.argv[1], sys.argv[2])
    extract_util("../../data/efficiency/util_coyote.csv", "../../data/efficiency/util_ushell.csv", "../../data/efficiency/util_inter_4.csv", "../../data/efficiency/util_inter_6.csv", "../../data/efficiency/util_inter_8.csv")
    print()
    print("=== Per-module utilization (resource_usage build) ===")
    extract_modules()

# python3 extract_util.py ../data/util_coyote.csv ../data/util_ushell.csv
