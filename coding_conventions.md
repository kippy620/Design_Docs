# FMRT SoC 代码规范

##**命名规则**

变量名应包含了以下三类信息：
* **变量的内容（它代表什么）**
* **数据的种类（具名常量、简单变量、用户自定义类型或者类）**
* **变量的作用域（私用的，类的、包的或者全局的作用域）**

-----
##**选择好变量名的注意事项**

###**最重要的命名注意事项**

为变量命名时最重要的考虑事项是，该名字要完全、准确地描述出该变量所代表的事物。获得好名字的一种实用技巧就是用文字表达变量所代表的是什么。通常，对变量的描述就是最佳的变量名。

###**以问题为导向**

一个好记的名字反映的通常都是问题，而不是解决方案。一个好名字通常表达的是 “什么”（what），而不是 “如何”（how）。

###**最适当的名字长度**

足够长，可以让你无须苦苦思索，同时避免名字太长了 —— 长得很不实用。

###**变量名中的计算值限定词**

很多程序都有表示计算结果的变量：总额、平均值、最大值等等。如果你要用类似于 Total、Sum、Average、Max、Min、Record、String、Pointer这样的限定词来修改某个名字，那么请记住把限定词加到名字的最后。

###**变量名对作用域的影响**

`W.J.Hansen` 所做的一项研究表明，较长的名字适用于很少用到的变量或者全局变量，而较短的名字则适用于局部变量或者循环变量（Shneiderman 1980）。不过，短的变量名常常会带来一些麻烦，因此，作为一项防御式编程策略，一些细心的程序员会避免使用短的变量名。

**对位于全局命名空间中的名字加以限定词** 如果你在全局命名空间中定义了一些变量（具体常量、类名等），那么请考虑你是否需要采用这种方式对全局命名空间进行划分，并避免产生命名冲突。

###**变量名中的常用对仗词的使用要准确**

-----
##**为特定类型的数据命名**

###**为状态变量命名**

**为状态变量取一个比 flag 更好的名字。**

###**为临时变量命名**

**警惕 “临时” 变量。**   临时性地保存一些值常常是很有必要的，应该重命名以更有意义的名字。

###**为布尔变量命名**

下面是为布尔变量命名时时要遵循的几条原则。
* **谨记典型的布尔变量名** 
* **使用肯定的布尔变量名**

###**为枚举类型命名**

在使用枚举类型的时候，可以通过使用组前缀，如 Color_，Planet_ 或者 Month_ 来表明该类型的成员都同属于一个组。

###**为常量命名**

在为具名常量时，应该根据该常量所表示的含义，而不是该常量所具有的数值为该抽象事物命名。

-----
##**非正式命名规则**

###**与语言无关的命名规则的指导原则**

下面给出用于创建一种与语言无关的命名规则的指导原则。
* **区分变量名和子程序名字** 变量名和对象名以小写字母开始，子程序名字以大写字母开始。
* **区分类和对象**  有很多标准的方案可用，如下例所示：

**方案1：通过大写字母开头区分类型和变量**
```python
Widget widget;
LongerWidget longerWidget;
```
**方案2：通过全部大写区分类型和变量**
```python
WIDGET widget;
LONGERWIDGET longerWidget;
```
**方案3：通过给类型加 “t_” 前缀区分类型和变量**
```python
t_Widget Widget;
t_LongerWidget LongerWidget;
```
**方案4：通过给变量加 “a” 前缀区分类型和变量**
```python
Widget aWidget;
LongerWidget aLongerWidget;
```
**方案5：通过对变量采用更明确的名字区分类型和变量**
```python
Widget employeeWidget;
LongerWidget fullEmployeeLongerWidget;
```
**标识全局变量**  有一种编程常见问题，那就是滥用全局变量。在所有的全局变量名之前加上 g_ 前缀。

**标识成员变量**   要根据名字识别出变量是类的数据成员。用 m_ 前缀来标识类的成员变量，以表明它是成员数据。

**标识类型变量**  为类型建立命名规则有两个好处：首先它能够明确表明一个名字是类型名，其次能够避免类型名与变量名冲突。为了满足这些要求，增加前缀或者后缀是不错的方法。

**标识具名常量**  你需要对具名变量加以标识，以便明确在为一个变量赋值时你用的是另一个变量的值（该值可能变化），还是一个具名常量。

**标识枚举类型的元素**  与具名常量相同，枚举类型的元素需要加以标识 —— 以便表明该名字表示的是枚举类型，而不是一个变量、具名常量或函数。标准方法如下：全部用大写，或者为类型名增加 e_ 或 E_ 前缀，同时为该类型的成员名增加基于特定类型的前缀，如 Color_ 或者 Planet_。

**在不能保证输入参数只读的语言里标识只读参数**  有时输入参数会被意外修改。

**格式化命名以提高可读性** 有两种常用方法可以用来提高可读性，那就是用大小写和分隔符来分隔单词。
尽量不要混用上述方法，那么会使代码难以阅读。

-----
##**创建具备可读性的短名字**

###**缩写的一般指导原则**

下面是几项用于创建缩写的指导原则。其中的一些原则彼此冲突，所以不要试图同时应用所有原则。
* **使用标准的缩写（列在字典中的那些常见缩写）。**
* **去掉所有非前置元音。（computer 变 cmptr，screen 变成 scrn，apple 变成 appl，integer 变成 intgr）**
* **去掉虚词 and，or，the等。**
* **使用每个单词的第一个或前几个字母。**
* **统一地在每个单词的第一、第二或者第三个（选择最合适的一个）字母后截断。**
* **保留每个单词的第一和最后一个字母。**
* **使用名字中的每一个重要单词，最多不超过三个。**
* **去除无用的后缀 —— ing，ed 等。**
* **确保不要改变变量的含义。**
* **反复使用上述技术，直到你把每个变量名的长度缩减到了 8 到 20 个字符，或者达到你所用的编程语言对变量名的限制字符数。**

###**有关缩写的评论**

在创建缩写的时候，会有很多的陷阱在等着你。下面是一些能够避免犯错的规则。
* **不要用从每个单词中删除一个字符的方式来缩写。** 
* **缩写要一致**  
* **创建你能读出来的名字**  
* **避免使用容易看错或者读错的字符组合** 
* **使用词典来解决命名冲突** 
* **在代码里用缩写对照表解释极短的名字的含义**  

**在一份项目级的 “标准缩写” 文档中说明所有的缩写**  代码中的缩写会带来的两种常见风险。
* **代码的读者可能不理解这些缩写。**
* **其他程序员可能会用多个缩写来代表相同的词，从而产生不必要的混乱。**

为了同时解决这两个潜在的问题，你可以创建一份 “标准缩写” 文档来记录项目中用到的全部编码的缩写。

**记住，名字对于代码读者的意义要比对作者更重要** 

-----
##**应该避免的名字**

下面就哪些变量名应该避免给出指导原则。
* **避免使用令人误解的名字或者缩写** 
* **避免使用具有相似含义的名字** 
* **避免使用具有不同含义但却有相似名字的变量**
* **避免使用发音相近的名字，比如 wrap 和 rap**
* **避免在名字中使用数字**  
* **避免使用英语中常常拼错的单词**  
* **不要仅依靠大小写区分变量名**  
* **避免使用多种自然语言**  
* **避免使用标准类型、变量和子程序的名字**  
* **不要使用与变量含义完全无关的名字** 
* **避免在名字中包含容易混淆的字符**

-----
##**总结**

* **好的变量名是提高程序可读性的一项关键要素。对特殊种类的变量，比如循环下标和状态变量，需要加以特殊的考虑。**
* **名字要尽可能地具体。那些太模糊或者太通用以致于能够用于多种目的的名字通常都是很不好的。**
* **命名规则应该能够区分局部数据、类数据和全局数据。它们还应该可以区分类型名、具名常量、枚举类型名字和变量名。**
* **无论做哪种类型项目，你都应该采用某种变量命名规则。你所采用的规则的种类取决于你的程序的规模，以及项目成员人数。**
* **代码阅读的次数远远多于编写的次数。确保你所取的名字更侧重于阅读方便而不是编写方便。**

-----
