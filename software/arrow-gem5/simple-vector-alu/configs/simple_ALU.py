# Importing the m5 library
import m5
# Importing all m5 SimObjects we've compiled
from m5.objects import *



# Creating the System SimObject
# Parent of all other objects in our simulated system
# It contains functional information, like physical 
# memory ranges, the root clock domain, the root voltage domain
# (Functional Information vs Timing Information)
system = System()

# Creating a root clock domain
system.clk_domain = SrcClockDomain()

# Setting the frequency of our root clock domain
system.clk_domain.clock = '3GHz'

# Creating a root voltage domain, and keeping it as default
system.clk_domain.voltage_domain = VoltageDomain()

# Setting up HOW the memory will be simulated & its size
# We will use timing mode for memory simulations
system.mem_mode = 'timing'
system.mem_ranges = [AddrRange('1024MB')]

# Creating a simple CPU that its timing-based
# Each instruction will be executed in a single clock cycle
# Exceptions are memory requests, which will flow through the memory system
system.cpu = MinorCPU()

# Creating a system-wide memory bus
system.membus = SystemXBar()

# No caches -> We connect the I-cache and the D-cache of our CPU
# to the system-wide memory bus 
# (CPU cache ports are masters and membus is slave)
# (Master = slave; or Slave = master in Python)
system.cpu.icache_port = system.membus.slave
system.cpu.dcache_port = system.membus.slave

# Creating I/O controller for our CPU; and connecting it to the memory bus
# This port is functional-only; and allows the system to read/write to memory
system.cpu.createInterruptController()
system.system_port = system.membus.slave

# Creating DDR3 memory controller, and connecting it to membus
# We also set the range to be equal to the address range we specified in
# system.mem_ranges's first element
system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR4_2400_16x4()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.master

# Adding SimpleALU Device
system.myALU = SimpleALU()
system.myALU.pio_addr ="0xBBBB0000"
system.myALU.pio_size ="0x68"
system.myALU.op_latency ='100ns'
system.myALU.pio_latency = '100ns'
system.myALU.warn_access = "Accessing ALU"
system.myALU.pio = system.membus.master

# We will run in System Call emulation mode
# It does not emulate all of the devices in a system, but rather focuses
# on simulating the CPU and memory system. System Call only emulates Linux System calls;
# and thus only models user-mode code (no kernel/Operating system code can be emulated!).
# Creating a process simobject & assigning it a workload
process = Process()
process.cmd = ['tests/test-progs/io_mapping/bin/io_mapping']

# Assigning the process as workload to the CPU
system.cpu.workload = process


# Create functional execution contexts in the CPU
system.cpu.createThreads()

# Instantiating the system by creating a Root SimObject
# then we begin the simulation
root = Root(full_system = False, system = system)

m5.instantiate()

# Mapping virtual address to physical address related to ISA fake
# Added to avoid being blocked by the Memory mapping unit
root.system.cpu.workload[0].map(0xBBBB0000,0xBBBB0000,104)

print("Beginning simulation!")
exit_event = m5.simulate()

print('Exiting @ tick {} because {}'
      .format(m5.curTick(), exit_event.getCause()))
