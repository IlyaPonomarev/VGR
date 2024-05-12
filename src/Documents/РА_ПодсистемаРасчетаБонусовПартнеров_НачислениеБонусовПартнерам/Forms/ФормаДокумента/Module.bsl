		
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	Если Объект.Ссылка.Пустая() Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Организации.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Организации КАК Организации
		|ГДЕ
		|	Организации.Наименование <> ""Управленческая организация""";
		
		ЗапросОрганизация= Запрос.Выполнить().Выгрузить();
		
		Если ЗапросОрганизация.Количество() = 1 Тогда
			Объект.Организация = ЗапросОрганизация[0].Ссылка;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Объект.Партнер) ИЛИ ЗначениеЗаполнено(Объект.Договор) Тогда
		ПолучитьДоступныеБонусныеПрограммы();	
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	ИспользоватьПартнеровКакКонтрагентов              = ПолучитьФункциональнуюОпцию("ИспользоватьПартнеровКакКонтрагентов");
	ИспользоватьНесколькоОрганизаций                  = ПолучитьФункциональнуюОпцию("ИспользоватьНесколькоОрганизаций");
	
КонецПроцедуры 

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды 
	
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Объект.ФиоФинДира = "Тихонова Е.А.";	
	КонецЕсли;	
	
КонецПроцедуры
#КонецОбласти


#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПартнерБезКЛПриИзменении(Элемент)
	ПриИзмененииПартнераСервер();
КонецПроцедуры

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура ДоговорПриИзменении(Элемент)
	ДоговорПриИзмененииНаСервере();		
КонецПроцедуры

&НаКлиенте
Процедура ПериодДействияПриИзменении(Элемент)
	ПолучитьДоступныеБонусныеПрограммы();
КонецПроцедуры

&НаКлиенте
Процедура ПартнерПриИзменении(Элемент)
		
	ПриИзмененииПартнераСервер();
	
КонецПроцедуры 

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыНачисленияРучнойРасчет

&НаКлиенте
Процедура НачисленияРучнойРасчетПриИзменении(Элемент)
	Объект.СуммаБонусовИтого = Объект.НачисленияАвтоматическийРасчет.Итог("СуммаБонуса") + Объект.НачисленияРучнойРасчет.Итог("СуммаБонуса");	
КонецПроцедуры
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Заполнить(Команда)
	ЗаполнитьНаСервере();
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ВводНаОснованииПриобретениеУслугИПрочихАктивов(Команда)
	
	Если Модифицированность ИЛИ Не Объект.Проведен Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю("Документ не проведен!");
		Возврат;
	КонецЕсли;

	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("Основание", Объект.Ссылка);
	
	ОткрытьФорму("Документ.ПриобретениеУслугПрочихАктивов.ФормаОбъекта", ПараметрыОткрытия);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

// СтандартныеПодсистемы.ПодключаемыеКоманды

&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
	ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

&НаСервере
Процедура ДоговорПриИзмененииНаСервере()
	
	Объект.Контрагент = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Договор, "Контрагент");
	ПолучитьДоступныеБонусныеПрограммы();
	Объект.НачисленияАвтоматическийРасчет.Очистить();
	Объект.СуммаБонусовИтого = Объект.НачисленияАвтоматическийРасчет.Итог("СуммаБонуса") + Объект.НачисленияРучнойРасчет.Итог("СуммаБонуса");	
КонецПроцедуры	

&НаСервере
Процедура ПолучитьДоступныеБонусныеПрограммы()
    
	ДокОбъект = РеквизитФормыВЗначение("Объект");
	ДокОбъект.ПолучитьДоступныеБонусныеПрограммы();
	ЗначениеВРеквизитФормы(ДокОбъект, "Объект");
	
	СгенерироватьСпискиВыбораПоДействующимБонуснымПрограммам();
	
КонецПроцедуры	

&НаСервере
Процедура СгенерироватьСпискиВыбораПоДействующимБонуснымПрограммам()
	
	СписокВыбора = ПолучитьСписокСписокВыбораПоРеквизиту("ПериодДействия");
	Элементы.ПериодДействия.СписокВыбора.ЗагрузитьЗначения(СписокВыбора);
	
КонецПроцедуры

&НаСервере
Функция ПолучитьСписокСписокВыбораПоРеквизиту(ИмяРеквизита)
	
	МассивЗначений = Новый Массив;
	
	Для Каждого БонуснаяПрограмма ИЗ Объект.ТаблицаДействующихБонусныхПрограмм Цикл
		МассивЗначений.Добавить(БонуснаяПрограмма[ИмяРеквизита]);	
	КонецЦикла;
	
	МассивЗначений = ОбщегоНазначенияКлиентСервер.СвернутьМассив(МассивЗначений);
	
	СписокВыбора = Новый СписокЗначений;
	
	Для Каждого ЭлементМассива ИЗ МассивЗначений Цикл
		СписокВыбора.Добавить(ЭлементМассива);	
	КонецЦикла; 
	
	Возврат МассивЗначений;
	
КонецФункции	

&НаСервере
Процедура ЗаполнитьДоговорПоУмолчанию()
	
	ВалютаВзаиморасчетовДляДоговора = Неопределено;
	
	//@skip-check wrong-string-literal-content
	ХозяйственнаяОперацияДоговора = ПредопределенноеЗначение("Перечисление.ХозяйственныеОперации.РеализацияКлиенту");
	
	Договор = ПродажиСервер.ПолучитьДоговорПоУмолчанию(Объект, 
													   ХозяйственнаяОперацияДоговора, 
													   ВалютаВзаиморасчетовДляДоговора,
													   ,
													   Ложь);
	
	Если Договор <> Объект.Договор Тогда
		Объект.Договор = Договор;
	КонецЕсли;
	
	ПолучитьДоступныеБонусныеПрограммы();
	
КонецПроцедуры

&НаСервере
Процедура ПриИзмененииПартнераСервер()
		
	ИспользоватьДоговорыСКлиентами = ПолучитьФункциональнуюОпцию("ИспользоватьДоговорыСКлиентами");
	Если ИспользоватьДоговорыСКлиентами Тогда
		ЗаполнитьДоговорПоУмолчанию();
	КонецЕсли;
	
	ПолучитьДоступныеБонусныеПрограммы();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаСервере()
	
	ДокОбъект = РеквизитФормыВЗначение("Объект");
	ДокОбъект.ЗаполнитьАвтоматическийРасчет();
	ЗначениеВРеквизитФормы(ДокОбъект, "Объект");
	
КонецПроцедуры 

#КонецОбласти
