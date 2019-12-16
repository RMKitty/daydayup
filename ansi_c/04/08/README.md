[TOC]


## 1. 浅拷贝

```c
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

typedef struct person
{
  char* name;

  void (*print)(struct person*);
  void (*copy)(struct person*, struct person*);
}person;

void print(person* p)
{
  printf("<struct person - %p> name_addr = %p\n", p, p->name);
}

void copy(person* ori, person* target)
{
  target->name = ori->name;
}

int main(int argc, char const *argv[])
{
  char* name = malloc(sizeof(char) * 64);
  bzero(name, 64);
  strcpy(name, "shabi 001");
  person      p = {name};
  p.print     = print;
  p.copy      = copy;
  p.print(&p);

  person copy;
  copy.print = print;
  p.copy(&p, &copy);
  copy.print(&copy);
}
```

```
╰─± make
<struct person - 0x7ffee7993ed0> name_addr = 0x7fc93fc02cc0
<struct person - 0x7ffee7993eb8> name_addr = 0x7fc93fc02cc0
```

- person 对象1: name 指向的 **内存地址** 0x7fc93fc02cc0
- person 对象2: name 指向的 **内存地址** 0x7fc93fc02cc0

这2个对象 name 成员, 指向 **同一个** 内存地址, 这就是 **浅拷贝**。



## 2. 重复释放 ==浅拷贝== 对象的成员

```c
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

typedef struct person
{
  char* name;

  void (*print)(struct person*);
  void (*copy)(struct person*, struct person*);
}person;

void print(person* p)
{
  printf("<struct person - %p> name_addr = %p\n", p, p->name);
}

void copy(person* ori, person* target)
{
  target->name = ori->name;
}

int main(int argc, char const *argv[])
{
  char* name = malloc(sizeof(char) * 64);
  bzero(name, 64);
  strcpy(name, "shabi 001");
  person      p = {name};
  p.print     = print;
  p.copy      = copy;
  p.print(&p);

  person copy;
  copy.print = print;
  p.copy(&p, &copy);
  copy.print(&copy);

  // 第一次 free 对象1 name 成员 => ok
  free(p.name);

  // 第二次 free 对象2 name 成员 => error
  free(copy.name);
}
```

```
╰─± make
<struct person - 0x7ffeedb8ced0> name_addr = 0x7f9e9ec02cc0
<struct person - 0x7ffeedb8ceb8> name_addr = 0x7f9e9ec02cc0
a.out(13778,0x10bcf55c0) malloc: *** error for object 0x7f9e9ec02cc0: pointer being freed was not allocated
a.out(13778,0x10bcf55c0) malloc: *** set a breakpoint in malloc_error_break to debug
make: *** [all] Abort trap: 6
```

进程崩溃。




## 3. 深拷贝

```c
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

typedef struct person
{
  char* name;

  void (*print)(struct person*);
  void (*deep_copy)(struct person*, struct person*);
}person;

void print(person* p)
{
  printf("<struct person - %p> name_addr = %p\n", p, p->name);
}

void deep_copy(person* ori, person* target)
{
  target->name = malloc(sizeof(char) * 64);
  bzero(target->name, 64);
  strcpy(target->name, ori->name);
}

int main(int argc, char const *argv[])
{
  char* name = malloc(sizeof(char) * 64);
  bzero(name, 64);
  strcpy(name, "shabi 001");
  person      p = {name};
  p.print     = print;
  p.deep_copy = deep_copy;
  p.print(&p);

  person deep_copy;
  deep_copy.print = print;
  p.deep_copy(&p, &deep_copy);
  deep_copy.print(&deep_copy);
}
```

```
╰─± make
<struct person - 0x7ffee079eed0> name_addr = 0x7fa0b0402cc0
<struct person - 0x7ffee079eeb8> name_addr = 0x7fa0b0402d00
```

- person 对象1: name 指向的 **内存地址** 0x7fa0b0402**cc0**
- person 对象2: name 指向的 **内存地址** 0x7fa0b0402**d00**

这2个对象 name 成员, 指向 **不同** 内存地址, 这就是 **深拷贝**。



## 4. 重复释放 ==深拷贝== 对象的成员

```c
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

typedef struct person
{
  char* name;

  void (*print)(struct person*);
  void (*deep_copy)(struct person*, struct person*);
}person;

void print(person* p)
{
  printf("<struct person - %p> name_addr = %p\n", p, p->name);
}

void deep_copy(person* ori, person* target)
{
  target->name = malloc(sizeof(char) * 64);
  bzero(target->name, 64);
  strcpy(target->name, ori->name);
}

int main(int argc, char const *argv[])
{
  char* name = malloc(sizeof(char) * 64);
  bzero(name, 64);
  strcpy(name, "shabi 001");
  person      p = {name};
  p.print     = print;
  p.deep_copy = deep_copy;
  p.print(&p);

  person deep_copy;
  deep_copy.print = print;
  p.deep_copy(&p, &deep_copy);
  deep_copy.print(&deep_copy);

  // 第一次 free 对象1 name 成员 => ok
  free(p.name);

  // 第二次 free 对象2 name 成员 => ok
  free(deep_copy.name);
}
```

```
╰─± make
<struct person - 0x7ffee1bd4ed0> name_addr = 0x7f9218402cc0
<struct person - 0x7ffee1bd4eb8> name_addr = 0x7f9218402d00
```

正常执行结束。



## 5. 比较 浅拷贝 与 深拷贝 ==实例成员指向的内存地址== 

```c
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

typedef struct person
{
  char* name;

  void (*print)(struct person*);
  void (*copy)(struct person*, struct person*);
  void (*deep_copy)(struct person*, struct person*);
}person;

void print(person* p)
{
  printf("<struct person - %p> name_addr = %p, &name = %p\n", p, p->name, &(p->name));
}

void copy(person* ori, person* target)
{
  target->name = ori->name;
}

void deep_copy(person* ori, person* target)
{
  target->name = malloc(sizeof(char) * 64);
  bzero(target->name, 64);
  strcpy(target->name, ori->name);
}

int main(int argc, char const *argv[])
{
  char* name = malloc(sizeof(char) * 64);
  bzero(name, 64);
  strcpy(name, "shabi 001");
  person      p = {name};
  p.print     = print;
  p.copy      = copy;
  p.deep_copy = deep_copy;
  p.print(&p);

  person copy;
  copy.print = print;
  p.copy(&p, &copy);
  copy.print(&copy);

  person deep_copy;
  deep_copy.print = print;
  p.deep_copy(&p, &deep_copy);
  deep_copy.print(&deep_copy);
}
```

```
╰─± make
<struct person - 0x7ffee0c11ed8> name_addr = 0x7f9c5bc02cc0, &name = 0x7ffee0c11ed8
<struct person - 0x7ffee0c11eb8> name_addr = 0x7f9c5bc02cc0, &name = 0x7ffee0c11eb8
<struct person - 0x7ffee0c11e98> name_addr = 0x7f9c5bc02d00, &name = 0x7ffee0c11e98
```

| 序号 | 对象 | 实例变量 name 自身的 内存地址 | 实例变量 name 指向的 内存地址 |
| --- | --------------- | ----------------------------- | ----------------------------- |
| 1 | **原始** 对象   | 0x7ffee0c11ed8                | 0x7f9c5bc02**cc0**            |
| 2 | **浅拷贝** 对象 | 0x7ffee0c11eb8                | 0x7f9c5bc02**cc0**            |
| 3 | **深拷贝** 对象 | 0x7ffee0c11e98                | 0x7f9c5bc02d00                |
| 结论 |             | 1、2、3 都不相同                | 1、2 相同 |

