#ifndef __SIMPLE_ALU_HH__
#define __SIMPLE_ALU_HH__

#include <string>

#include "dev/io_device.hh"
#include "mem/packet.hh"
#include "params/SimpleALU.hh"

/**
 * IsaFake is a device that returns, BadAddr, 1 or 0 on all reads and
 *  rites. It is meant to be placed at an address range
 * so that an mcheck doesn't occur when an os probes a piece of hw
 * that doesn't exist (e.g. UARTs1-3), or catch requests in the memory system
 * that have no responders..
 */
class SimpleALU : public BasicPioDevice
{
  protected:
    uint8_t configRegister;
    uint8_t operand1[4];
    uint8_t operand2[4];
    uint8_t result[4];

    EventFunctionWrapper event;
    EventFunctionWrapper event1;
    void processEvent();
    void processEvent1();

    /** Delay that the device experinces on an access. */
    Tick deviceOperationDelay;

  public:
    typedef SimpleALUParams Params;
    const Params *
    params() const
    {
        return dynamic_cast<const Params *>(_params);
    }
    /**
      * The constructor for Isa Fake just registers itself with the MMU.
      * @param p params structure
      */
    SimpleALU(Params *p);

    /**
     * This read always returns -1.
     * @param pkt The memory request.
     * @param data Where to put the data.
     */
    virtual Tick read(PacketPtr pkt);

    /**
     * All writes are simply ignored.
     * @param pkt The memory request.
     * @param data the data to not write.
     */
    virtual Tick write(PacketPtr pkt);
};

#endif // __SIMPLE_ALU_HH__
