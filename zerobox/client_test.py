import rpyc

c = rpyc.connect("localhost", 18861)
print(c.root.detect())
print(c.root.get_status())
print(c.root.connect())
print(c.root.get_status())
print(c.root.disconnect_cameras())
print(c.root.get_status())