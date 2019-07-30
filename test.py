import cppyy

cppyy.cppdef('class A{};')

print(cppyy.gbl.A())
