
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура РА_ПодсистемаРасчетаБонусовПартнеров_НачБонусовПартнерамПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	ЭлементФормы = Элементы.Добавить("Элемент_ФорматОтгрузки", Тип("ПолеФормы"), Элементы.ГруппаПараметрыПраво);
	
	ЭлементФормы.Заголовок = "Формат отгрузки";  
	ЭлементФормы.Вид = ВидПоляФормы.ПолеВвода;
	ЭлементФормы.ПутьКДанным = "Объект.РА_ПодсистемаРасчетаБонусовПартнеров_ФорматОтгрузки";
КонецПроцедуры

#КонецОбласти
