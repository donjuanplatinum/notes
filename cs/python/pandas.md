# Pandas
强大的文档处理接口 支持众多格式的处理和转换

支持的格式: CSV,JSON,SQL,Excel,HTML等等

## 抽象
在Pandas中 使用`pandas.DataFrame`类来保存表

按照行row 和列column

它是一个2维数组 其中每一列是`pandas.Series`类

**其中 DataFrame的索引idx为列的键 返回一个列** 

## 数据接口
- `pd.read_csv(file)`: 读取CSV返回DataFrame

