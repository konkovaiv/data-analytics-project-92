----------Первый отчет о десятке лучших продавцов
select
	concat(e.first_name,e.last_name) as empl_name, --- объединяем фамилию и имя продавцов
	count(*)as operations, --- считаем количество сделок
	ROUND(MAX(p.price*s.quantity),0) as income --- считаем выручку и округляем до целого числа
from sales s 
inner join employees e --- джойним таблицу с продавцами
on s.sales_person_id =e.employee_id 
inner join products p --- джойним таблицу с продуктами
on p.product_id = s.product_id 
group by empl_name --- группируем по имени работника
order by income desc ---сортируем от большего к меньшему
limit 10 --- ограничиваем выборку до 10 позиций

--------- Второй отчет о о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
select(select ------- используем подзапрос, чтобы посчитать общую среднюю выручку
	round(avg((p.price*s.quantity)),0) --- считаем общую среднюю выручку, округляем до целого
	from products p 
	inner join sales s  --- джойним таблицу сейлс к таблице продуктов
	on p.product_id=s.product_id) as avgincome, 
concat(e.first_name,e.last_name) as empl_name, --- объединяем фамилию и имя продавцов
ROUND(avg(p.price*s.quantity),0) as average_income --- считаем среднюю выручку и округляем до целого числа
from sales s 
inner join employees e --- джойним таблицу с продавцами
on s.sales_person_id =e.employee_id 
inner join products p --- джойним таблицу с продуктами
on p.product_id = s.product_id 
group by empl_name --- группируем по имени работника
having AVG(p.price*s.quantity) < 267166 --- отфильтровываем по условию
order by average_income  ---сортируем по возрастанию

-------------Третий отчет по информации о выручке по дням недели
select
	concat(e.first_name,e.last_name) as empl_name, --- объединяем фамилию и имя продавцов
	to_char(s.sale_date, 'DAY')as weekday, --- преобразовываем дату в день недели
	ROUND(sum(p.price*s.quantity),0) as income --- считаем выручку и округляем до целого
from sales s 
inner join employees e --- джойним таблицу с продавцами
on s.sales_person_id =e.employee_id 
inner join products p --- джойним таблицу с продуктами
on p.product_id = s.product_id 
group by empl_name,weekday --- группируем 
order by weekday --- сортируем

----------количество покупателей в разных возрастных группах:
select 
  case ----- задаем условия группировок по возрастам
    WHEN age >=16 AND age <=25 THEN '16-25'
    WHEN age >=26 AND age <=40 THEN '26-40'
    WHEN age >=40 THEN '40+'
  END as age_category,
  count(age) as count
FROM
  customers c 
  group by age_category     
  order by age_category
  
  -------данные по количеству уникальных покупателей и выручке, которую они принесли
select 
to_char(s.sale_date, 'yyyy-mm') as date, --- преобразовываем дату в формат год-месяц
count(c.*) as total_customers, --- считаем кол-во клиентов
ROUND(SUM(p.price*s.quantity),0) as income --- считаем выручку и округляем до целого
from sales s 
inner join customers c --- джойним таблицу с покупателями
on s.customer_id =c.customer_id
inner join products p  --- джойним таблицу с продуктами
on p.product_id = s.product_id 
group by date  --- группируем по дате
order by date --- сортируем по дате

---------покупатели, первая покупка которых была в ходе проведения акций 
select
c.customer_id,
concat(c.first_name,c.last_name) as customer, 
MIN(s.sale_date) as sale_date, --- используем MIN чтобы выдать самую раннюю дату продажи
concat(e.first_name,e.last_name) as seller
from products p 
inner join sales s 
on s.product_id = p.product_id 
inner join employees e 
on s.sales_person_id =e.employee_id 
inner join customers c 
on s.customer_id = c.customer_id 
where p.price = 0 --- фильтруем по стоимости, чтобы отображались только акционные товары
group by p.product_id, seller, customer,c.customer_id 
order by c.customer_id 
 