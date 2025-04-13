// 论文模板 - 使用 Typst 编写

// 设置文档基本参数
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),


  numbering: "1",
)

// 设置标题样式
#set heading(numbering: "1.1")

// 字体设置
#set text(
  font: ("Times New Roman", "SimSun"),
  size: 12pt,
  
)

// 封面页
#pagebreak()
#align(center + horizon)[
  #text(size: 16pt, weight: "bold")[论文标题]

  #v(2em)

  #text(size: 14pt)[作者姓名]

  #v(1em)

  #text(size: 12pt)[
    学校名称 \
    学院名称 \
    
  ]
]

// 摘要页
#pagebreak()
#heading(level: 1)[摘要]
#lorem(200) // 这里用随机文本代替实际摘要
#v(1em)
#text(weight: "bold")[关键词：] 关键词1, 关键词2, 关键词3

#pagebreak()
#heading(level: 1)[Abstract]
#lorem(150) // English abstract placeholder
#v(1em)
#text(weight: "bold")[Keywords: ] keyword1, keyword2, keyword3

// 目录
#pagebreak()
#heading(level: 1)[目录]
#outline()

// 正文开始
#pagebreak()
#heading(level: 1)[引言]
#lorem(300) // 引言内容占位符

#heading(level: 1)[相关工作]
#heading(level: 2)[研究背景]
#lorem(200)

#heading(level: 2)[国内外研究现状]
#lorem(250)

#heading(level: 1)[研究方法]
#lorem(300)

#heading(level: 1)[实验结果]
#figure(
  caption: [实验数据对比],
  image("placeholder.png", width: 80%), // 替换为实际图片路径
)

#heading(level: 1)[结论]
#lorem(200)

// 参考文献
#pagebreak()
#heading(level: 1)[参考文献]
#bibliography("references.bib") // 需要实际的.bib文件

// 附录
#pagebreak()
#heading(level: 1)[附录]
#heading(level: 2)[附录A 数据表格]
#table(
  caption: [示例数据],
  columns: 4,
  [标题1], [标题2], [标题3], [标题4],
  [数据1], [数据2], [数据3], [数据4],
  [数据5], [数据6], [数据7], [数据8],
)