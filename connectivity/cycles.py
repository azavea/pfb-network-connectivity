import nxutils
import networkx as nx

n = nxutils.NXUtils('cambridge')
n.buildNetwork()
DG = n.getNetwork()
fullCycles = len(list(nx.simple_cycles(DG)))
print('Number of cycles for all stress')
print(fullCycles)

MG = n.getStressNetwork(2)
stressCycles = len(list(nx.simple_cycles(SG)))
print('Number of cycles for medium stress')
print(fullCycles)

SG = n.getStressNetwork(1)
stressCycles = len(list(nx.simple_cycles(SG)))
print('Number of cycles for low stress')
print(fullCycles)
