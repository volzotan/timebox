import rpyc

c = rpyc.connect("localhost", 18861)
print(c.root.init())
print(c.root.run())