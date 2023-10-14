#include "arrow/simple_alu.hh"

#include "base/trace.hh"
#include "debug/SimpleALU.hh"
#include "mem/packet.hh"
#include "mem/packet_access.hh"
#include "sim/system.hh"

using namespace std;

SimpleALU::SimpleALU(Params *p)
    : BasicPioDevice(p, p->pio_size), event([this]{ processEvent(); },name() + ".event"), event1([this]{ processEvent1(); },name() + ".event"), deviceOperationDelay(p->op_latency)
{
    DPRINTF(SimpleALU, "Created the Simple ALU\n");
}

void SimpleALU::processEvent1()
{
  DPRINTF(SimpleALU, "Resetting bit\n");
  // Control Register
  // Bit 0 : Ready Bit
  // Bit 1 :
  // Bit 2/3 : Specify operation
  // 00 add; 01 sub; 10 mul; 11 div

  configRegister &= 0xfe;
  
}

void SimpleALU::processEvent()
{
  DPRINTF(SimpleALU, "Performing an operation\n");
  // Control Register
  // Bit 0 :
  // Bit 1 :
  // Bit 2/3 : Specify operation
  // 00 add; 01 sub; 10 mul; 11 div
  
  uint8_t op = configRegister & 0x0C;
  // Code for addition
  if(op==0x00)
  {
    for (int i=0; i<4; i++)
    {
      result[i]=operand1[i]+operand2[i];
    }

  }
  else if (op==0x04)
  {
      // Code for subtraction
  for (int i=0; i<4; i++)
  {
    result[i]=operand1[i]-operand2[i];
  }
  }
  else if (op==0x08)
  {
        // Code for multiplication
  for (int i=0; i<4; i++)
  {
  result[i]=operand1[i]*operand2[i];
  }
  }
  else if (op==0x0C)
  {
    // Code for division
  for (int i=0; i<4; i++)
  {
    if(operand2[i]==0)
    {
      panic("Division by Zero detected in the SimpleALU!\n");
    }
    result[i]=operand1[i]/operand2[i];
  }
  }


  configRegister |= 0x01;



}

Tick
SimpleALU::read(PacketPtr pkt)
{
    pkt->makeAtomicResponse();

    if (params()->warn_access != "")
    {
        warn("Device %s accessed by read to address %#x size=%d\n",
                name(), pkt->getAddr(), pkt->getSize());
    }
    
        assert(pkt->getAddr() >= pioAddr && pkt->getAddr() < pioAddr + pioSize);

        DPRINTF(SimpleALU, "read  va=%#x size=%d\n",
                pkt->getAddr(), pkt->getSize());

        if(pkt->getAddr()==pioAddr)
        {
          pkt->setLE(configRegister);
        }
        else if (pkt->getAddr()==pioAddr+0x08)
        {
          pkt->setLE(operand1[0]);
        }
        else if (pkt->getAddr()==pioAddr+0x10)
        {
          pkt->setLE(operand1[1]);
        }
        else if (pkt->getAddr()==pioAddr+0x18)
        {
          pkt->setLE(operand1[2]);
        }
        else if (pkt->getAddr()==pioAddr+0x20)
        {
          pkt->setLE(operand1[3]);
        }
        else if (pkt->getAddr()==pioAddr+0x28)
        {
          pkt->setLE(operand2[0]);
        }
        else if (pkt->getAddr()==pioAddr+0x30)
        {
          pkt->setLE(operand2[1]);
        }
        else if (pkt->getAddr()==pioAddr+0x38)
        {
          pkt->setLE(operand2[2]);
        }
        else if (pkt->getAddr()==pioAddr+0x40)
        {
          pkt->setLE(operand2[3]);
        }
        else if (pkt->getAddr()==pioAddr+0x48)
        {
          pkt->setLE(result[0]);
        }
        else if (pkt->getAddr()==pioAddr+0x50)
        {
          pkt->setLE(result[1]);
        }
        else if (pkt->getAddr()==pioAddr+0x58)
        {
          pkt->setLE(result[2]);
        }
        else if (pkt->getAddr()==pioAddr+0x60)
        {
          pkt->setLE(result[3]);
        }
        else
        {
          panic("invalid access size! Device being accessed by cache?\n");
        }
    
    return pioDelay;
}

Tick
SimpleALU::write(PacketPtr pkt)
{
    pkt->makeAtomicResponse();

    if (params()->warn_access != "") {
        uint64_t data;
        switch (pkt->getSize()) {
          case sizeof(uint8_t):
            data = pkt->getLE<uint8_t>();
            break;
          default:
            panic("invalid access size: %u\n", pkt->getSize());
        }
        

        warn("Device %s accessed by write to address %#x size=%d data=%#x\n", 
            name(), pkt->getAddr(), pkt->getSize(), data);
    }

    assert(pkt->getAddr() >= pioAddr && pkt->getAddr() < pioAddr + pioSize);

    DPRINTF(SimpleALU, "write - va=%#x size=%d \n",
         pkt->getAddr(), pkt->getSize());

    if (pkt->getSize()==sizeof(uint8_t))
    {
      if(pkt->getAddr()==pioAddr)
        {
          configRegister = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x08)
        {
          operand1[0] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x10)
        {
          operand1[1] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x18)
        {
          operand1[2] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x20)
        {
          operand1[3] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x28)
        {
          operand2[0] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x30)
        {
          operand2[1] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x38)
        {
          operand2[2] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x40)
        {
          operand2[3] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x48)
        {
          result[0] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x50)
        {
          result[1] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x58)
        {
          result[2] = pkt->getLE<uint8_t>();
        }
        else if (pkt->getAddr()==pioAddr+0x60)
        {
          result[3] = pkt->getLE<uint8_t>();
        }
        else{
           panic("invalid access size! Device being accessed by cache?\n");
        }        
    }
    else
    {
        panic("invalid access size!\n");
    }

    schedule(event1, curTick() + 1);
    schedule(event, curTick() + deviceOperationDelay);

    return pioDelay;
}

SimpleALU* SimpleALUParams::create()
{
    return new SimpleALU(this);
}
