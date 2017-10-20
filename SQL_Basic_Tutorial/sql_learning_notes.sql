/*此书很生动形象的介绍了RDBMS的标准SQL语句以及基本的功能, 主要是DML语句，也就是数据操纵语句，
但不涉及中高级的一些用法 */

-- Database: shop

-- DROP DATABASE shop;
-- 添加数据库
CREATE DATABASE shop
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- 新增表   
CREATE TABLE Shohin
(shohin_id      CHAR(4)      NOT NULL,
 shohin_mei     VARCHAR(100) NOT NULL,
 shohin_bunrui  VARCHAR(32)  NOT NULL,
 hanbai_tanka   INTEGER      ,
 shiire_tanke   INTEGER      ,
 torokubi       DATE         ,
 PRIMARY KEY (shohin_id));

-- 添加列或删除列 
ALTER TABLE Shohin ADD COLUMN Shohin_mei_kana VARCHAR(100);
ALTER TABLE Shohin DROP COLUMN Shohin_mei_kana;

-- 插入数据
BEGIN TRANSACTION;
INSERT INTO Shohin VALUES ('0001', 'T恤衫', '衣服', 1000, 500, '2009-09-20');
INSERT INTO Shohin VALUES ('0002', '打孔器', '办公用品', 500, 320, '2009-09-11');
INSERT INTO Shohin VALUES ('0003', '运动T恤', '衣服', 4000, 2800, NULL);
INSERT INTO Shohin VALUES ('0004', '菜刀', '厨房用具', 3000, 2800, '2009-09-20');
INSERT INTO Shohin VALUES ('0005', '高压锅', '厨房用具', 6800, 5000, '2009-01-15');
INSERT INTO Shohin VALUES ('0006', '叉子', '厨房用具', 500, NULL, '2009-09-20');
INSERT INTO Shohin VALUES ('0007', '擦菜板', '厨房用具', 880, 790, '2008-04-28');
INSERT INTO Shohin VALUES ('0008', '圆珠笔', '办公用品', 100, NULL, '2009-11-11');
COMMIT;

--表重命名
ALTER TABLE Shohin RENAME TO Sohin;
COMMIT;

--取数据并取别名,设置中文别名时使用双引号
select shohin_id as "身份", shohin_bunrui as "类别" from shohin  

--查询常数
select '2017-10-19' as "日期", 38 as kazu,shohin_id from shohin

--去重 DISTINCT 
select DISTINCT shohin_bunrui, torokubi from shohin

--选取某一列为NULL的数据 IS NULL 
--逻辑运算符 NOT, AND, OR

--使用括号()可改变优先级
select * from shohin where shiire_tanke > 500 
AND ( shohin_bunrui = '衣服' OR shohin_bunrui = '办公用品');

--SQL有真、假、UNKNOWN三种逻辑值

--WHERE只能指定行（记录）的条件，HAVING 用来指定组的条件（分组中）
select shohin_bunrui,count(*) from shohin where torokubi > '2009-01-01' group by shohin_bunrui；
select shohin_bunrui,count(*) from shohin where torokubi > '2009-01-01' group by shohin_bunrui HAVING count(*) >2；

--创建表时设定默认值之后，插入数据时可使用DEFAULT来插入默认值
--从其他表中复制数据
INSERT INTO ShohinIns SELECT * FROM Shohin;

--删除表及表中数据
DROP TABLE; --整张表删除
DELETE FROM TABLE; --表中的数据删除，但表还存在
DELETE FROM TABLE WHERE ;-- 删除表中符合条件的行
TRUNCATE TABLE; --部分RDBMS中支持,删除表中全部数据，速度比delete快，但只可删除全部数据

--更新表中数据(两种方法)
UPDATE Shohin SET hanbai_tanka = hanbai_tanka*10, shiire_tanka = shiire_tanka/2
WHERE shohin_bunrui = '厨房用具';
UPDATE Shohin SET (hanbai_tanka, shiire_tanka) = (hanbai_tanka*10, shiire_tanka/2)
WHERE shohin_bunrui = '厨房用具';  --此方法在部分DBMS中可用

--事务是需要在同一个处理单元中执行的一系列更新处理的集合。
BEGIN TRANSACTION;
COMMIT; --SQL SERVER , POSTGRESQL

START TRANSACTION;
COMMIT; -- MYSQL

COMMIT; --ORACLE, DB2  没有定义特定的开始语句，由于标准SQL中规定了一种悄悄开始事务处理的方法
/*事务处理开始有两种情况：（数据库连接建立后，事务便悄悄开始了）
1、每条SQL语句就是一个事务（自动提交模式）
2、直到用户执行COMMIT或者ROLLBACK为止算一个事务*/
COMMIT; --提交处理
ROLLBACK; --取消处理
/*事务的ACID特性，A：原子性 Atomicity    C: 一致性 Consistency 
  I:隔离性 Isolation  D： 持久性 Durability   */
  
--视图：保存从表中取出数据所使用的SELECT语句，可将经常使用的SELECT语句做成视图
CREATE VIEW ShohinSum (shohin_bunrui, cnt_shohin)
AS SELECT shohin_bunrui, COUNT(*) FROM Shohin GROUP BY shohin_bunrui;  --创建视图

DROP VIEW ShohinSum  --删除视图
DROP VIEW ShohinSum CASCADE   --若试图有关联视图，可通过此语句删除

--子查询，尽量为子查询设立名称，便于内容处理
SELECT * FROM 
(SELECT shohin_bunrui, COUNT(*) AS cnt_shohin
 FROM shohin
 GROUP BY shohin_bunrui)
AS ShohinSum;

--标量子查询（返回单一值的子查询）
SELECT * FROM Shohin WHERE hanbai_tanka > 
(SELECT AVG(hanbai_tanka) FROM Shohin);

--关联子查询（关联条件需要写在子查询中）
SELECT * FROM Shohin AS S1 
WHERE hanbai_tanka > (SELECT AVG(hanbai_tanka) FROM Shohin AS S2
                      WHERE S1.shohin_bunrui = S2.shohin_bunrui  --表S1与表S2关联
					  GROUP BY shohin_bunrui);
					  
/* SQL自带函数
算数：+, -, *, /, 求余(MOD,或 %), ROUND, ABS ;
字符串: 拼接( || 或 + 或 CONCAT), 字符串长度(字节数)( LENTH 或 LEN),字符数(CHAR_LENGTH  MySQL中)
        大小写(LOWER, UPPER),  REPLACE, SUBSTRING ;
日期: CURRENT_TIMESTAMP, EXTRACT(YEAR FROM CURRENT_TIMESTAMP),  
转换函数: CAST(值 AS 数据类型), COALESCE()返回参数中第一个不是NULL的值, 
*/

/*谓词：返回真值
LIKE谓词： %（代表0或以上个任意字符）,  _(下划线代表1个任意字符)
LIKE 'abc%', LIKE '%abc', LIKE '%abc%',前、后、中方一致匹配, LIKE 'abc__'
BETWEEN谓词：BETWEEN a AND b, (指在a, b中间, 且包含a, b)
IS NULL,IS NOT NULL谓词: 判断是否为NULL
IN, NOT IN谓词: IN (a, b, c) 在此范围内, 可在子查询中使用使两表联立
                SELECT *FROM Shohin WHERE shohin_id 
				IN (SELECT shohin_id FROM TenpoShohin 
				    WHERE tenpo_id = '000C');
EXISTS, NOT EXISTS谓词: 通常指定关联子查询作为参数
                SELECT *FROM Shohin AS S 
				WHERE EXISTS (SELECT * FROM TenpoShohin AS TS
							WHERE TS.tenpo_id = '000C'
							AND TS.shohin_id = S.shohin_id);      */

/* CASE表达式
搜索CASE表达式：CASE WHEN <> THEN <>
					 WHEN <> THEN <>
					 ELSE <>
				END
简单CASE表达式: CASE <>      此行中书写过之后便无需在WHEN语句中书写
					 WHEN <> THEN <>
					 WHEN <> THEN <>
					 ELSE <>
				END				
SELECT shohin_mei,
	   CASE WHEN shohin_bunrui = '衣服' THEN 'A' || shohin_bunrui
	        WHEN shohin_bunrui = '办公用品' THEN 'B' || shohin_bunrui
			ELSE NULL
		END AS abc_shohin_bunrui
FROM Shohin;	*/

/*集合运算
UNION：表的加法 SELECT * FROM Shohin UNION SELECT * FROM Shohin2;
				SELECT * FROM Shohin UNION ALL SELECT * FROM Shohin2;  ALL 选项可保存重复项，且不会排序，因此性能更快
INTERSECT: 表的交集(公共部分)
EXCEPT：表的差集（减法）

JOIN: 联结 SELECT TS.tenpo_id, TS.tenpo_mei, TS.shohin_id, S.shohin_mei, S.hanbai_tanka
           FROM TenpoShohin AS TS INNER JOIN Shohin AS S on TS.shohin_id = S.shohin_id;
联结分为内联结和外联结, 且通过LEFT和RIGHT选定主表(INNER JION, LEFT OUTER JOIN, RIGHT OUTER JOIN)
CROSS JOIN: (交叉联结)两张表的笛卡尔积
除法运算！！！书中未详细说明
*/

/*SQL高级处理
窗口函数： <窗口函数> OVER (PARTITION BY <> ORDER BY <>)
可作为窗口函数使用的函数：1、聚合函数(SUM, AVG, COUNT, MAX, MIN) 
						  2、专用窗口函数(RANK, DENSE_RANK, ROW_NUMBER)(三种排序的方式不同, [1,1,1,4],[1,1,1,2],[1,2,3,4])
SELECT shohin_mei, shohin_bunrui, hanbai_tanka,
	   RANK() OVER (PARTITION BY shohin_bunrui     --PARTITION BY 用途是分组，在组内排序
	                ORDER BY hanbai_tanka) AS ranking   --ORDER BY 此处的主要用途是窗口函数计算的排序, 并非对表的真实的排序
FROM Shohin ORDER BY ranking;    --此处的ORDER BY 才是对输出结果的排序

还可在窗口函数中指定除(PARTITION BY)窗口外更细节的统计范围, "框架"
SELECT shohin_mei, shohin_bunrui, hanbai_tanka,
	   AVG(hanbai_tanka) OVER (ORDER BY shohin_id
	                          ROWS 2 PRECEDING) AS moving_avg  --ROWS 2 PRECEDING 表示截止到之前2行
FROM Shohin;
--ROWS 2 FOLLOWING  --表示到之后2行
--ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING  --表示 之前1行，自身，以及之后1行

GROUPING运算符：除了GROUP BY的分组值之外，还可以同时计算合计值(ROLLUP, CUBE, GROUPING SETS)
SELECT CASE WHEN GROUPING(shohin_bunrui) = 1  --使用GROUPING给超级分组记录中的键值插入字符串(GROUPING可判别超级分组产生的NULL)
			THEN '商品种类 合计'
			ELSE shohin_bunrui END AS shohin_bunrui,
	   CASE WHEN GROUPING(torokubi) = 1
			THEN '登记日期 合计'
			ELSE CAST(torokubi AS VARCHAR(16)) END AS torokubi,  --统一CASE各分支输出的格式
		SUM(hanbai_tanka) AS sum_tanka      --计算合计、小计、分组求和
FROM Shohin
GROUP BY ROLLUP(shohin_bunrui,torokubi);  --ROLLUP计算(1.GROUP BY() 2.GROUP BY(shohin_bunrui) 3.GROUP BY(shohin_bunrui,torokubi))
--GROUP BY CUBE(shohin_bunrui,torokubi); --CUBE计算(1. 2. 3.GROUP BY(torokubi)比ROLLUP新增 4. )(聚合键所有组合的可能)
--GROUP BY GROUPING SETS (shohin_bunrui,torokubi); --可设置计算的范围，此处只计算了(1.GROUP BY(shohin_bunrui) 2.GROUP BY(torokubi))
*/








