Pre-built kernel modules are located under `ls /lib/modules/$(uname -r)/kernel/`. Modules have the suffix `.ko`. If a module is in compressed .gz format, it must be uncompressed before loaded. Modules can depend on other modules. 

Basic commands for working with kernel modules:
```sh
lsmod
insmod    # loads a single decompressed module
modprobe  # automatic decompression and dependency loading
rmmod
```


Any Linux driver consists of a constructor and a destructor. 

* module_init() gets called whenever insmod succeeds in loading the module into the kernel. 
* module_exit() gets called whenever rmmod succeeds in unloading the module out of the kernel.

These constructor are macros from `module.h`.

The basic skeleton of a linux module:
```c
#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>

static int __init mymod_init(void) /* Constructor */
{
    printk(KERN_INFO "mymod registered");

    return 0;
}

static void __exit mymod_exit(void) /* Destructor */
{
    printk(KERN_INFO "mymod unregistered");
}

module_init(mymod_init);
module_exit(mymod_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Halvor Saether <email@halvorsaether.com>");
MODULE_DESCRIPTION("My first linux driver");
```

The header `version.h` is included for version compatibility of the module with the kernel into which it is going to get loaded.
