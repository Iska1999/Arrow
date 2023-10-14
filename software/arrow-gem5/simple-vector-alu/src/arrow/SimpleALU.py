from m5.params import *
from m5.proxy import *
from m5.objects.Device import BasicPioDevice

class SimpleALU(BasicPioDevice):
    type = 'SimpleALU'
    cxx_header = "arrow/simple_alu.hh"

    # Parameters that come from the BasicPioDevice
    pio_latency = Param.Latency('100ns', "Programmed IO latency")

    # Parameters that come from the ISAFake SimObject
    pio_size = Param.Addr(0x68, "Size of address range")
    warn_access = Param.String("", "String to print when device is accessed")

    # Custom Parameter
    op_latency = Param.Latency('100ns', "Time taken to perform vector operations")
