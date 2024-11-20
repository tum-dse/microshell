**AXI4-Stream Switch: [Working]**
- Purpose-built for spatial routing between multiple streams
- Uses TDEST field on input interfaces to control routing decisions
- Supports one-to-one, one-to-many, and many-to-one connections
- More deterministic routing behavior
- Better suited when you need to actively control which input goes to which output

**AXI4-Stream Interconnect: [Not working since TDEST is an output]**
- More focused on TDM and arbitration
- Better suited for aggregating multiple streams into one (multiplexing)
- TDEST is an output that indicates source, not a routing control
- Round-robin arbitration may not give you the precise control you need
- Better when you need to merge streams or handle backpressure

