
#Область СлужебныеПроцедурыИФункции

&После("ОбработкаЗаполнения")
Процедура РА_ПодсистемаРасчетаБонусовПартнеровОбработкаЗаполнения(Объект, ДанныеЗаполнения, СтандартнаяОбработка) Экспорт
	Если ТипЗнч(ДанныеЗаполнения) <> Тип("ДокументСсылка.РА_ПодсистемаРасчетаБонусовПартнеров_НачислениеБонусовПартнерам") Тогда
		Возврат;
	КонецЕсли;	
	
	Объект.Партнер = ДанныеЗаполнения.Партнер;
	
	//Добавим значение в табличную часть документа 
	
	//@skip-check unknown-method-property
	СтрокаРасходы = Объект.Расходы.Добавить();
	СтрокаРасходы.Количество = 1;
	СтрокаРасходы.СтавкаНДС = ПредопределенноеЗначение("Справочник.СтавкиНДС.БезНДС");
	СтрокаРасходы.Содержание = "";
	СтрокаРасходы.Сумма = ДанныеЗаполнения.СуммаБонусовИтого;
	СтрокаРасходы.СуммаВзаиморасчетов = ДанныеЗаполнения.СуммаБонусовИтого;
	СтрокаРасходы.СуммаСНДС = ДанныеЗаполнения.СуммаБонусовИтого;
	СтрокаРасходы.СуммаВзаиморасчетов = ДанныеЗаполнения.СуммаБонусовИтого;
	СтрокаРасходы.Цена = ДанныеЗаполнения.СуммаБонусовИтого;
	
КонецПроцедуры

#КонецОбласти
