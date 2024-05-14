#Область ОбработчикиСобытийФормы

&НаСервере
Процедура РА_ПодсистемаРасчетаБонусовПартнеровПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	РА_ПодсистемаРасчетаБонусовПартнеров_ДобавитьЭлементыНаФорму();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура РА_ПодсистемаРасчетаБонусовПартнеров_ДобавитьЭлементыНаФорму()

	НовыйЭлемент = Элементы.Добавить("РА_ОсновнойДоговор", Тип("ПолеФормы"), Элементы.ГруппаШапкаЛево);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
	НовыйЭлемент.ПутьКДанным = "Объект.РА_ПодсистемаРасчетаБонусовПартнеров_ОсновнойДоговор";
	НовыйЭлемент.УстановитьДействие("ПриИзменении",
		"РА_ПодсистемаРасчетаБонусовПартнеров_Подключаемый_ОсновнойДоговорПриИзменении");
	НовыйЭлемент.Подсказка = "Если договор кредитный, необходимо указать основной договор, для корректного расчета бонусов";
	НовыйЭлемент.ОтображениеПодсказки = ОтображениеПодсказки.Кнопка;

КонецПроцедуры

&НаКлиенте
Процедура РА_ПодсистемаРасчетаБонусовПартнеров_Подключаемый_ОсновнойДоговорПриИзменении(Элемент)

	Если Объект.Ссылка = Объект.РА_ПодсистемаРасчетаБонусовПартнеров_ОсновнойДоговор Тогда
		Объект.РА_ПодсистемаРасчетаБонусовПартнеров_ОсновнойДоговор = ПредопределенноеЗначение(
			"Справочник.ДоговорыКонтрагентов.ПустаяСсылка");
	КонецЕсли;

КонецПроцедуры

#КонецОбласти






