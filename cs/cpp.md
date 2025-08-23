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
### 元素删除
```cpp
int k {0};
for (int i {0};i < array.len;++i) { // i遍历数组
	if (array[i] != target) { // 不是目标元素则递增k
		array[k] = array[i]; // 将i补到k
		k++; 
	}
	array.len = k; // 修改边界
}
```
## 程序(C)
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
### 最大的行
```c
#include <stdio.h>
#define IN 1
#define OUT 0
#define MAX 1000
int _getline(char s[],int lim) {
  int i = 0;
  char c;
  while (i < lim -1 &&(  c = getchar()) != EOF && c != '\n') {
    s[i] = c;
    ++i;
  }
  if (c == '\n') {
    s[i] = c;
    ++i;
  }
  s[i] = '\0';
  return i;
}
void copy(char from[], char to[]) {
  int i = 0;
  while (from[i] != '\0') {
    to[i] = from[i];
    ++i;
  }
  to[i] = '\0';
}
int main() {
  char c;
  char string[MAX];
  int len = 0;
  int max_len = 0;
  char max[MAX];
  while ((len = _getline(string, MAX)) > 0) {
    printf("%d",len);
    if (len > max_len) {
      copy(string, max);
      max_len = len;
      }
  }
  printf("%s",max);
}

```
### 截断尾部空白
```c
void delete_tail_whitespace(char s[], int len) {
  int index = len -1;
  int add =0;
  if (s[index] == '\n' && index == 0) {
    s[index] = '\0';
	return ;
  }
  if (s[index] != '\n') {
    add = 0;
  } else {add = 1;}
  while (index > 0 && (s[index] == ' '|| s[index] == '\t' || s[index] == '\n')) {
    s[index] = '\0';
    --index;
  }
  if (add == 1) {
    s[(++index)] = '\n';
  }
}
```

### 制表换空格
行处理
```c
int _getline_detab(char s[],int max){
  char c;
  int i = 0;
  while (i < max - 1 && ((c = getchar()) != EOF) && c != '\n') {
if (c != '\t'){
	s[i] = c;
	++i;
      } else {
	int count = 8 - (i % 8);
	while (count >0) {
	  s[i] = ' ';
	  ++i;
	  --count;
	}
      }
  }
  if (c == '\n') {
      s[i] = '\n';
      ++i;
    }
  s[i] = '\0';
  return i;
}
```
逐字处理
```c

void detab(char s[]){
  int c;
  int count = 0; 
  int pos = 0;
  while ( (c = getchar()) != EOF){
    if (c == '\t'){
      pos %= 8;
      count = 8 - pos;
      while (count >0) {
	putchar(' ');
	--count;
      }
      pos =0;
    } else  {
      putchar(c);
      ++pos;
	  if (c == '\n') {
		  pos = 0;
	  }
    }

  }
}
```
### 空格换制表
```c
void entab(char s[]) {
  int num_space = 0;
  int num_tab = 0;
  int pos = 0;
  char c;
  while ( (c = getchar()) != EOF) {
    ++pos;
    if (c == ' ') {
      if ((pos % TABINC) != 0) {
	++num_space;
      } else {
	num_space = 0;
	++num_tab;
      }
    } else {
      while (num_tab> 0) {
	putchar('\t');
	--num_tab;
      }
      if (c == '\t') {
	num_space =0;
      } else {
	while (num_space >0) {
	  putchar(' ');
	  --num_space;
	}
      }
      putchar(c);
      if (c == '\n') {
	pos = 0;
      } else if (c == '\t') {
	pos = pos + (TABINC - (pos - 1) % TABINC) - 1;
      }
    }
  }
  
}
```
### 获得n低位全为1的屏蔽码
```c
~(~0 << n)
```
