#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/version.h>
#include <linux/init.h>
#include <linux/device.h>
#include <linux/pci.h>
#include <linux/ioport.h>
#include <asm/unistd.h>
#include <linux/slab.h>
#include <linux/fs.h>
#include <linux/types.h>
#include <asm/uaccess.h>
#include <asm/io.h>
#include <linux/kdev_t.h>
#include <asm/fcntl.h>
#include <linux/sched.h>
#include <linux/wait.h>
#include <linux/errno.h>
#include <linux/kfifo.h>
#include <asm/irq.h>
#include <asm/errno.h>
#include <asm/ioctl.h>
#include <linux/string.h>
#include <linux/interrupt.h>
#include <linux/cdev.h>
#include <linux/spinlock.h>
#include <linux/seq_file.h>
#include <linux/proc_fs.h>

#define MAX_BUFFSIZE (5 * 1024)
//#define err 0
#define PCDD_IOC_MAGIC				'H'
#define PCDD_IOC_RESET 				_IO(PCDD_IOC_MAGIC, 0)
#define PCDD_IOC_BYTES_COUNT		_IOR(PCDD_IOC_MAGIC,1,int)
#define PCDD_IOC_MAX				2


static dev_t pcdd_dev;
//static struct cdev *pcdd_cdev;

static struct class *pseudo_class; /* pretend /sys/class */

static int __init pcdd_init(void);
static void __exit pcdd_exit(void);

static int pcdd_open(struct inode *inode, struct file *file);
static int pcdd_release(struct inode *inode, struct file *file);
/*__kfifo_init
ss__kfifo_init __user *, size_t, loff_t *);
  __kfifo_inite *, const char __user *, size_t, loff_t *);
*/
static ssize_t pcdd_read(struct file *file, char __user *buff, size_t count, loff_t *pos);
static ssize_t pcdd_write(struct file *file, const char __user *buff, size_t count, loff_t *pos);

long pcdd_ioctl(struct file *file, unsigned int pcdd_cmd, unsigned long arg);

//this private object has been created as per rules of character
//device and in addition, each instance of this private object
//is used to represent a pseudo device instance managed by
//this driver !!!
typedef struct priv_obj1
{
	struct list_head list;
	dev_t dev; //device id of a specific device instance !!
	struct cdev cdev;
	unsigned char *buff; //kernel buffer used with kfifo object
						 //	struct kfifo *kfifo;  //kfifo object ptr - older technique
	struct kfifo kfifo;  //kfifo object must be preallocated,
						 //in newer versions of the kernel- newer technique !!!
	//size_t	esize;
	spinlock_t my_lock;
	wait_queue_head_t queue; //you may need more than one wq
} C_DEV;

static struct file_operations pcdd_fops = {
	.open = pcdd_open,
	.read = pcdd_read,
	.write = pcdd_write,
	.release = pcdd_release,
	.unlocked_ioctl = pcdd_ioctl,
	.owner = THIS_MODULE,
};

LIST_HEAD(dev_list);
int ndevices = 1;

static int pcdd_open(struct inode *inode, struct file *file)
{
	C_DEV *obj;
	obj = container_of(inode->i_cdev, C_DEV, cdev);
	file->private_data = obj;
	dump_stack();
	//must complete open method - ???
	printk("Driver : opend device\n");
	return 0;
}

static int pcdd_release(struct inode *inode, struct file *file)
{
	printk("Driver : closed device\n");
	return 0;
}
//in a typical driver/device context,
//*pos(points to filebyte offset field of open file object of
//this device file) is to be ignored - meaning, there is no
//concept of logical file byte no. for a device file/device data , typically !!!
static ssize_t pcdd_read(struct file *file, char __user *buff,
						 size_t count, loff_t *pos)
{
	C_DEV *dev;
	unsigned int bytes;
	char *temp_buffer;

	dev = file->private_data;
	printk("inside read call...\n");


	if(access_ok(VERIFY_WRITE, (void __user *)buff, (unsigned long)count))
	{

		bytes = kfifo_len(&(dev->kfifo));
		printk(KERN_INFO "Kfifo Len bytes: %d",bytes);
		if(bytes == 0)
		{
			if (file->f_flags & O_NONBLOCK)
			{
				return -EAGAIN;
			}
			else
			{
				wait_event_interruptible(dev->queue,(kfifo_len(&dev->kfifo) != 0));
			}
		}

		temp_buffer = kmalloc(count, GFP_KERNEL);
		if(temp_buffer == NULL)
		{
			printk(KERN_ALERT "Error while allocating buffer");
			return -EFAULT;
		}

		bytes = kfifo_out_spinlocked(&dev->kfifo, (void *)temp_buffer, count, &dev->my_lock);

		raw_copy_to_user(buff, temp_buffer, count);
		kfree(temp_buffer);

		wake_up_interruptible(&dev->queue);

		//bytes = kfifo_out(&(dev->kfifo), (void *) buff, count);
		return bytes;
	}
	else
	{
		return -EFAULT;
	}
}
//in the first driver assignment, wake up responsibilty will be
//that of write() method for processepcdd_read,s blocked in read() method
//and vice-versa - however, this willpcdd_read, not be true in further drivers,
//where other mechanisms are used forpcdd_read, wake-up of blocked processes !!!!
/*
static ssize_t pcdd_write(struct file *file,const char __user *buff,size_t count,loff_t *pos);

*/
static ssize_t pcdd_write(struct file *file, const char __user *buff, size_t count, loff_t *pos)
{
	C_DEV *dev;
	unsigned int bytes;
	char *temp_buffer;
	dev = file->private_data;
	printk("inside write call...\n");

	if(access_ok(VERIFY_READ, (void __user *)buff, (unsigned long) count))
	{
		bytes = kfifo_avail(&dev->kfifo);
		if(bytes == 0)
		{
			if(file->f_flags & O_NONBLOCK)
			{
				return -EAGAIN;
			}
			else
			{
				wait_event_interruptible(dev->queue, (kfifo_avail(&(dev->kfifo))) != 0);
			}
		}
		temp_buffer = kmalloc(count, GFP_KERNEL);
		if(temp_buffer == 0)
		{
			printk(KERN_ALERT "Error while allocating buffer");
			return -EFAULT;
		}

		raw_copy_from_user(temp_buffer, buff, count);
		
		bytes = kfifo_in_spinlocked(&dev->kfifo, (void *)temp_buffer, count, &dev->my_lock);
		kfree(temp_buffer);
		
		wake_up_interruptible(&dev->queue);

		return bytes;
	}
	else
	{
		return -EFAULT;
	}


}

long pcdd_ioctl(struct file *file, unsigned int pcdd_cmd, unsigned long arg)
{
	//void __user *argp = (void __user *)arg;
	long bytes;
	C_DEV *dev = file->private_data;
	printk("Inside pcdd_ioctl()\n");
	//dump_stack();
	printk(KERN_ALERT "pcdd_ioctl: process %i(%s)\n", current->pid, current->comm);

	if (_IOC_TYPE(pcdd_cmd) != PCDD_IOC_MAGIC)
	{
		return -ENOTTY;
	}
	if (_IOC_NR(pcdd_cmd) != PCDD_IOC_MAX)
	{
		return -ENOTTY;
	}
	
	switch (pcdd_cmd)
	{
	case PCDD_IOC_RESET:
	{
		//reset_dev(dev);
		kfifo_reset(&dev->kfifo);
	}
	break;
	case PCDD_IOC_BYTES_COUNT:
	{
		printk(KERN_ALERT "pcdd_ioctl: get len\n");
		//Write to userspace
		bytes = put_user(kfifo_len(&dev->kfifo), (unsigned int *)arg);
	}
	break;
	default:
		break;
	}
	return bytes;
}

module_param(ndevices, int, S_IRUGO);

C_DEV *my_dev;
static int __init pcdd_init(void)
{
	int i, ret = 0;
	if (alloc_chrdev_region(&pcdd_dev, 0, ndevices, "pseudo_driver")) //creating device ids for each device & storing it into corresponding device pcdd_dev
	{
		printk("Error in device creating.....\n");
		//err |= EBUSY;
		goto error;
	}

	//pseudo_class = class_create(THIS_MODULE, "pseudo_driver");

	// pseudo_class = class_create(THIS_MODULE, "pseudo_driver");
	// if (IS_ERR(pseudo_class))
	// {
	// 	printk(KERN_ERR "plp_kmem: Error creating class.\n");
	// 	//cdev_del(pcdd_dev);
	// 	unregister_chrdev_region(pcdd_dev, 1);
	// 	//ADD MORE ERROR HANDLING
	// 	goto error;
	// }

	printk("1: alloc_chrdrv_region end\n");
	for (i = 0; i < ndevices; i++)
	{
		//kmalloc is an API provided by slab allocator
		//subsystem of physical memory manager !!!
		//there are several allocator mechanisms
		//provided by physical memory manager !!

		//flags are used for PMM
		//in this case, a default flag of
		//GFP_KERNEL is used !!!
		my_dev = kmalloc(sizeof(C_DEV), GFP_KERNEL); //create memory for pseduo devices
		if (my_dev == NULL)
		{
			printk("Error in creatinpcdd_read,g devices....\n");
			if (i >= 1) //error checking for second device onwards
			{
				//err |= -ENOMEM;
				goto error;
			}
			else
			{
				unregister_chrdev_region(pcdd_dev, ndevices);
				return -ENOMEM;
			}
		}
		printk("2 %d: kmallic for my_dev\n", i);
		list_add_tail(&my_dev->list, &dev_list); //???	//add to list queue of device
		printk("3 %d: list add tail\n", i);

		my_dev->buff = kmalloc(MAX_BUFFSIZE, GFP_KERNEL);
		if (my_dev->buff == NULL)
		{
			printk(KERN_ALERT "Error when creating buffer");
			goto error;
			// printk("Error in allocating memory for device buffer....\n");
			// if (i >= 1)
			// {

			// 	kfree(my_dev);
			// 	//err |= -ENOMEM;
			// 	goto error;
			// }
			// else
			// {

			// 	kfree(my_dev);
			// 	unregister_chrdev_region(pcdd_dev, ndevices);
			// 	return -ENOMEM;
			// }
		}
		printk("4 %d: kmalloc buffer\n", i);
		init_waitqueue_head(&my_dev->queue);//Initialze the queue
		spin_lock_init(&(my_dev->my_lock));
		printk("5: %d spin_lock init\n", i);
		//this spin lock requires an initialization !!!
		//refer to <ksrc>/include/linux/kfifo.h
		//and <ksrc>/kernel/kfifo.c for more details !!!
		//
		//my_dev->kfifo = kfifo_init(my_dev->kfifo,(void *)MAX_BUFFSIZE,
		                               //    GFP_KERNEL,my_dev->esize);

		//the below API is for newer kernel versions
		ret = kfifo_init(&(my_dev->kfifo), my_dev->buff, MAX_BUFFSIZE);

		if (ret)
		{
			printk("Error in initializing kfifo.....\n");
			printk(KERN_ALERT "Error in initializing kfifo...");
			// if (i >= 1)
			// {
			// 	kfree(my_dev->buff);
			// 	kfree(my_dev);
			// 	//err |= -ENOMEM;
			// 	goto error;
			// }
			// else
			// {
			// 	kfree(my_dev->buff);
			// 	kfree(my_dev);
			// 	unregister_chrdev_region(pcdd_dev, ndevices);
			// 	return -ENOMEM;
			// }
		}
		printk("6: %d kfifo init\n", i);

		cdev_init(&(my_dev->cdev), &pcdd_fops); //initialse current device's operation with our written file operations
		printk("7: %d cdev init\n", i);
		kobject_set_name(&(my_dev->cdev.kobj), "device%d", i); //give name to current device
		printk("8: %d kobj_set_name\n", i);
		my_dev->cdev.ops = &pcdd_fops;
		my_dev->cdev.owner = THIS_MODULE;
		printk("9: %d my_dev->cdev.ops\n", i);
		my_dev->dev = pcdd_dev + 1;
		

		if (cdev_add(&(my_dev->cdev), pcdd_dev + i, 1) < 0)
		//if (cdev_add(&(my_dev->cdev), pcdd_dev + i, 1))
		{
			printk("Error in cdev adding....\n");
			kobject_put(&(my_dev->cdev.kobj));
			printk(KERN_ALERT "Error in cdev adding");
			// if (i >= 1)
			// {
			// 	kfifo_free(&my_dev->kfifo);
			// 	kfree(my_dev->buff);
			// 	kfree(my_dev);
			// 	unregister_chrdev_region(pcdd_dev, ndevices);
			// 	//err |= -EBUSY;
			// 	goto error;
			// }
			// else
			// {
			// 	kfifo_free(&my_dev->kfifo);
			// 	kfree(my_dev->buff);
			// 	kfree(my_dev);
			// 	unregister_chrdev_region(pcdd_dev, ndevices);
			// 	return -EBUSY;
			// }
		}

		printk(KERN_INFO "MINOR %d and MAJOR %d", MINOR(pcdd_dev), MAJOR(pcdd_dev));
		pseudo_class = class_create(THIS_MODULE, "pseudo_class");
		if (IS_ERR(pseudo_class))
		{
			printk(KERN_ERR "pcdd_dev: Error creating class.\n");
			cdev_del(&(my_dev->cdev));
			unregister_chrdev_region(pcdd_dev, 1);
			//ADD MORE ERROR HANDLING
			goto error;
		}
		device_create(pseudo_class, NULL, pcdd_dev, NULL,"pseudo_dev0");
		//device_create(pseudo_class, NULL, pcdd_dev, "pseudo_dev0");
		printk("10: %d cdev_add\n", i);
	}
	printk(KERN_INFO "pcdd : loaded\n");
	return 0;

error:
{
	//must complete error handling
	/********ASSIGNMENT****************************/
	//unregister_chrdev_region(pcdd_dev, ndevices);
	kfifo_free(&(my_dev->kfifo));
	cdev_del(&(my_dev->cdev));
	//kfree(my_dev->buff);
	kfree(my_dev);
	/**********************************************/

	return -ENOMEM; //use a variable to set the error code
					//return the same variable from each point of error
}
}

static void __exit pcdd_exit(void)
{
	//int i;
	/********ASSIGNMENT****************************/
	//unregister_chrdev_region(pcdd_dev, ndevices);
	device_destroy(pseudo_class, pcdd_dev);
	class_destroy(pseudo_class);
	kfifo_free(&my_dev->kfifo);
	cdev_del(&(my_dev->cdev));
	//kfree(my_dev->buff);
	kfree(my_dev);
	/********ASSIGNMENT****************************/

	//must complete this method,in your assignment  ??

	printk("pcdd : unloading\n");
}

module_init(pcdd_init);
module_exit(pcdd_exit);

MODULE_DESCRIPTION("Pseudo Device Driver");
MODULE_ALIAS("memory allocation");
MODULE_LICENSE("GPL");
MODULE_VERSION("0:1.0");