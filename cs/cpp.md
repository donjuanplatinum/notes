# CPP


## 技巧
### IO优化
在保证不混用cin/scanf,cout/prinf情况下 关闭Cpp与C的IO同步
```cpp
std::ios::sync_with_stdio(false)
```


解除输入与输出的关联
```c++
std::cin.tie(nullptr)
```

注意
## 程序
### 单词计数
```c
#include <stdio.h>
#define IN 1
#define OUT 0
int main() {
  int lines = 0;
  int words = 0;
  int stat = OUT;
  char c;
  while ((c = getchar()) != EOF) {
    if (c == '\n') {
      ++lines;
    }
    if (c == ' ' || c == '\n' || c == '\t') {
stat = OUT;
      putchar('\n');
    } else if (stat == OUT) {
	stat = IN;
	++words;
      }
    
    
  }
  printf("words: %d,lines: %d",words,lines);
}

```
### 单词长度直方图
```c
#include <stdio.h>
#define IN 1
#define OUT 0
int main() {
  int lines = 0;
  int words = 0;
  int stat = OUT;
  int words_len = 0;
  char c;
  while ((c = getchar()) != EOF) {
    if (c == ' ' || c == '\n' || c == '\t') {
      if (stat == IN) {
	while (words_len > 0) {
	  putchar('-');
	  --words_len;
	}
      }
      stat = OUT;
      
    } else {
      if (stat == OUT) {
	stat = IN;
        ++words;
	putchar('\n');
      }
      putchar(c);
      ++words_len;
      
    }
  }

  if (stat == IN) {
    while (words_len > 0) {
      putchar('-');
      --words_len;
    }
  }
}

```
### 字符计数
```c
#include <stdio.h>
#define IN 1
#define OUT 0
int main() {
  int lines = 0;
  int words = 0;
  int stat = OUT;
  int words_len = 0;
  char c;
  char set[127];

  for (int i=48;i<127;++i) {
    set[i] = 0;
  }

  while ( (c = getchar()) != EOF) {
    ++set[c^0];
  }
  printf("\n Character[ANSI]:count");
  for (int i = 48; i < 127; ++i) {
    printf("\n %c[%d]:%d",i,i,set[i]);
  }
}
```
