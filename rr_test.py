import cppyy

cppyy.add_include_path("/tmp/CPyCppyy/src/")

cppyy.cppdef("""
#include <iostream>
#include "Python.h"
#include "Cppyy.h"
#include "MemoryRegulator.h"

class B : public TObject {
public:
   ~B() {
      std::cout << "B destructor" << std::endl;
   }
};

class A : public TObject {
private:
   B* b;
public:
   void setB(B* bp) { b = bp; }

   ~A() {
      std::cout << "A destructor" << std::endl;
      CPyCppyy::MemoryRegulator::RecursiveRemove(b, Cppyy::GetScope("B"));
      delete b;
   }
};
""")

def create():

    f = cppyy.gbl.A()
    t = cppyy.gbl.B()
    f.setB(t)

    return f, t

f, t = create()

print("END OF APP --------------------")

