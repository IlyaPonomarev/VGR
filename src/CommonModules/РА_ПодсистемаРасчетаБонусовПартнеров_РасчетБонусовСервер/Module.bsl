
#Область СлужебныеПроцедурыИФункции 

Процедура ОбработатьНачислениеБонусов(ДокументОбъект, ВнешнийВызов = Ложь) Экспорт

	УстановитьПривилегированныйРежим(Истина);

	Движения = ДокументОбъект.Движения;
	
	Движения.РА_ПодсистемаРасчетаБонусовПартнеров_БонусыПартнерам.Записывать = Истина;
	Движения.РА_ПодсистемаРасчетаБонусовПартнеров_БонусыПартнерам.Очистить();
	Движения.РА_ПодсистемаРасчетаБонусовПартнеров_БонусыПартнерам.Записать();
	
	СформироватьДвиженияПоДействующимБонуснымПрограммам(ДокументОбъект.Договор, ДокументОбъект.Дата, Движения, ДокументОбъект.Ссылка, ВнешнийВызов);
	
	Движения.РА_ПодсистемаРасчетаБонусовПартнеров_БонусыПартнерам.Записать();
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры	

Процедура СформироватьДвиженияПоДействующимБонуснымПрограммам(Знач Договор, ДатаДокумента, Движения, СсылкаНаДокумент, ВнешнийВызов = Ложь)

	РеквизитИсключитьИзБонусаСуществует = Метаданные.Документы.ЗаказКлиента.Реквизиты.Найти("ИсключитьИзБонуса")
		<> Неопределено;

	ТаблицаДействующихБонусныхПрограмм = ПолучитьДействующиеБонусныеПрограммы(Договор, ДатаДокумента);

	Если Не ТаблицаДействующихБонусныхПрограмм.Количество() Тогда
		//@skip-check wrong-string-literal-content
		ТаблицаДействующихБонусныхПрограмм = ПолучитьДействующиеБонусныеПрограммы(
			ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор, "РА_ПодсистемаРасчетаБонусовПартнеров_ОсновнойДоговор"),
			ДатаДокумента);
		Если ТаблицаДействующихБонусныхПрограмм.Количество() Тогда
			//@skip-check wrong-string-literal-content
			Договор = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор,
				"РА_ПодсистемаРасчетаБонусовПартнеров_ОсновнойДоговор");
		КонецЕсли;
	КонецЕсли;

	Если Не ТаблицаДействующихБонусныхПрограмм.Количество() Тогда
		//@skip-check wrong-string-literal-content
		ТаблицаДействующихБонусныхПрограмм = ПолучитьДействующиеБонусныеПрограммы(
			ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор, "Партнер"), ДатаДокумента);
	КонецЕсли;

	Если Не ТаблицаДействующихБонусныхПрограмм.Количество() Тогда
		Возврат;
	КонецЕсли;

	ДвиженияПоВыручке = Движения.ВыручкаИСебестоимостьПродаж;

	Если ВнешнийВызов Тогда
		ДвиженияПоВыручке = РегистрыНакопления.ВыручкаИСебестоимостьПродаж.СоздатьНаборЗаписей();
		ДвиженияПоВыручке.Отбор.Регистратор.Установить(СсылкаНаДокумент);
		ДвиженияПоВыручке.Прочитать();
	КонецЕсли;

	Для Каждого ДействующаяПрограммаБонуса Из ТаблицаДействующихБонусныхПрограмм Цикл

		МассивПроизводителейБонуснойПрограммы = ДействующаяПрограммаБонуса.Производители.ВыгрузитьКолонку(
				"Производитель");

		ДополнительнаяНоменклатураБонуснойПрограммы = ДействующаяПрограммаБонуса.ДополнительнаяНоменклатура.ВыгрузитьКолонку(
				"Номенклатура");

			//@skip-check query-in-loop
		МассивПодходящейНоменклатуры = ПолучитьМассивНоменклатурыДляРасчетаБонусовПоПлануЗакупок(
			МассивПроизводителейБонуснойПрограммы, ДополнительнаяНоменклатураБонуснойПрограммы);

#Область РасчетБонусовПоПлануЗакупок

		Если ДействующаяПрограммаБонуса.ТипПоказателяПлана <> ПредопределенноеЗначение(
			"Перечисление.РА_ТипыПоказателяПлана.НетПлана") Тогда

			Для Каждого СтрокаДвиженияВыручка Из ДвиженияПоВыручке Цикл

				Если СтрокаДвиженияВыручка.РасчетСебестоимости Тогда
					Продолжить;
				КонецЕсли;

				Если РеквизитИсключитьИзБонусаСуществует И ЗаказИсключаетсяИзБонусов(
					СтрокаДвиженияВыручка.ЗаказКлиента) Тогда
					Продолжить;
				КонецЕсли;

				НоменклатураВыручки = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
					СтрокаДвиженияВыручка.АналитикаУчетаНоменклатуры, "Номенклатура");

				РеквизитыНоменклатуры = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(НоменклатураВыручки,
					"Производитель, РА_ВходитВБазуБонусовПриЗакупках");

				Если МассивПодходящейНоменклатуры.Найти(НоменклатураВыручки) <> Неопределено
					И РеквизитыНоменклатуры.РА_ВходитВБазуБонусовПриЗакупках Тогда

					Движение = Движения.РА_ПодсистемаРасчетаБонусовПартнеров_БонусыПартнерам.ДобавитьПриход();
					Движение.Период = СтрокаДвиженияВыручка.Период;
					Движение.Активность = Истина;

					Движение.АналитикаУчетаБонуснойПрограммы = ДействующаяПрограммаБонуса.БонуснаяПрограммаСсылка;

					Движение.Номенклатура = НоменклатураВыручки;
					Движение.ТипПремии = ПредопределенноеЗначение(
						"Перечисление.РА_ТипыПремийПартнерам.ПремияЗаВыполнениеПлана");
					Движение.ПроцентПремии = ДействующаяПрограммаБонуса.ПроцентПремииЗаПланЗакупок;
					Движение.СуммаВыручки = СтрокаДвиженияВыручка.СуммаВыручкиРегл;
					Движение.Сумма = СтрокаДвиженияВыручка.СуммаВыручкиРегл
						* ДействующаяПрограммаБонуса.ПроцентПремииЗаПланЗакупок / 100;
				КонецЕсли;

			КонецЦикла;

		КонецЕсли;

#КонецОбласти

#Область РасчетБонусовЗаШоуРум

		Если ДействующаяПрограммаБонуса.ПроцентПремииЗаШоуРум <> 0 Тогда

			Для Каждого СтрокаДвиженияВыручка Из ДвиженияПоВыручке Цикл

				Если СтрокаДвиженияВыручка.РасчетСебестоимости Тогда
					Продолжить;
				КонецЕсли;

				Если РеквизитИсключитьИзБонусаСуществует И ЗаказИсключаетсяИзБонусов(
					СтрокаДвиженияВыручка.ЗаказКлиента) Тогда
					Продолжить;
				КонецЕсли;

				НоменклатураВыручки = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
					СтрокаДвиженияВыручка.АналитикаУчетаНоменклатуры, "Номенклатура");

				РеквизитыНоменклатуры = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(НоменклатураВыручки,
					"Производитель, РА_ВходитВБазуБонусовПриЗакупках");

				Если МассивПодходящейНоменклатуры.Найти(НоменклатураВыручки) <> Неопределено
					И РеквизитыНоменклатуры.РА_ВходитВБазуБонусовПриЗакупках Тогда

					Движение = Движения.РА_ПодсистемаРасчетаБонусовПартнеров_БонусыПартнерам.ДобавитьПриход();
					Движение.Период = СтрокаДвиженияВыручка.Период;
					Движение.Активность = Истина;

					Движение.АналитикаУчетаБонуснойПрограммы = ДействующаяПрограммаБонуса.БонуснаяПрограммаСсылка;

					Движение.Номенклатура = НоменклатураВыручки;
					Движение.ТипПремии = ПредопределенноеЗначение(
						"Перечисление.РА_ТипыПремийПартнерам.ПремияЗаНаличиеШоуРума");
					Движение.ПроцентПремии = ДействующаяПрограммаБонуса.ПроцентПремииЗаШоуРум;
					Движение.СуммаВыручки = СтрокаДвиженияВыручка.СуммаВыручкиРегл;
					Движение.Сумма = СтрокаДвиженияВыручка.СуммаВыручкиРегл
						* ДействующаяПрограммаБонуса.ПроцентПремииЗаШоуРум / 100;

				КонецЕсли;

			КонецЦикла;

		КонецЕсли;

#КонецОбласти

#Область РасчетБонусовЗаСложныйПродукт

		Если ДействующаяПрограммаБонуса.ПроцентПремииЗаСложныйПродукт <> 0 Тогда

			Для Каждого СтрокаДвиженияВыручка Из ДвиженияПоВыручке Цикл

				Если СтрокаДвиженияВыручка.РасчетСебестоимости Тогда
					Продолжить;
				КонецЕсли;

				Если РеквизитИсключитьИзБонусаСуществует И ЗаказИсключаетсяИзБонусов(
					СтрокаДвиженияВыручка.ЗаказКлиента) Тогда
					Продолжить;
				КонецЕсли;

				НоменклатураВыручки = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
					СтрокаДвиженияВыручка.АналитикаУчетаНоменклатуры, "Номенклатура");

				РеквизитыНоменклатуры = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(НоменклатураВыручки,
					"Производитель, РА_СложныйПродукт");

				Если МассивПодходящейНоменклатуры.Найти(НоменклатураВыручки) <> Неопределено
					И РеквизитыНоменклатуры.РА_СложныйПродукт Тогда

					Движение = Движения.РА_ПодсистемаРасчетаБонусовПартнеров_БонусыПартнерам.ДобавитьПриход();
					Движение.Период = СтрокаДвиженияВыручка.Период;
					Движение.Активность = Истина;

					Движение.АналитикаУчетаБонуснойПрограммы = ДействующаяПрограммаБонуса.БонуснаяПрограммаСсылка;

					Движение.Номенклатура = НоменклатураВыручки;
					Движение.ТипПремии = ПредопределенноеЗначение(
						"Перечисление.РА_ТипыПремийПартнерам.ПремияЗаСложныйПродукт");
					Движение.ПроцентПремии = ДействующаяПрограммаБонуса.ПроцентПремииЗаСложныйПродукт;
					Движение.СуммаВыручки = СтрокаДвиженияВыручка.СуммаВыручкиРегл;
					Движение.Сумма = СтрокаДвиженияВыручка.СуммаВыручкиРегл
						* ДействующаяПрограммаБонуса.ПроцентПремииЗаСложныйПродукт / 100;

				КонецЕсли;

			КонецЦикла;

		КонецЕсли;

#КонецОбласти

#Область РасчетБонусовЗаФорматОтгрузки

		Если ДействующаяПрограммаБонуса.НастройкиПремийПоВидамОборудования.Количество() Тогда

			Для Каждого СтрокаДвиженияВыручка Из ДвиженияПоВыручке Цикл

				Если СтрокаДвиженияВыручка.РасчетСебестоимости Тогда
					Продолжить;
				КонецЕсли;

				Если РеквизитИсключитьИзБонусаСуществует И ЗаказИсключаетсяИзБонусов(
					СтрокаДвиженияВыручка.ЗаказКлиента) Тогда
					Продолжить;
				КонецЕсли;

				ФорматОтгрузкиЗаказа = ФорматОтгрузкиЗаказа(СтрокаДвиженияВыручка.ЗаказКлиента);

				СтрокиПоФорматуОтгрузки = ДействующаяПрограммаБонуса.НастройкиПремийПоФорматамОтгрузки.НайтиСтроки(
					Новый Структура("ФорматОтгрузки", ФорматОтгрузкиЗаказа));

				Для Каждого СтрокаПоФорматуОтгрузки Из СтрокиПоФорматуОтгрузки Цикл

					НоменклатураВыручки = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
					СтрокаДвиженияВыручка.АналитикаУчетаНоменклатуры, "Номенклатура");

					Если МассивПодходящейНоменклатуры.Найти(НоменклатураВыручки) <> Неопределено Тогда

						Движение = Движения.РА_ПодсистемаРасчетаБонусовПартнеров_БонусыПартнерам.ДобавитьПриход();
						Движение.Период = СтрокаДвиженияВыручка.Период;
						Движение.Активность = Истина;

						Движение.АналитикаУчетаБонуснойПрограммы = ДействующаяПрограммаБонуса.БонуснаяПрограммаСсылка;

						Движение.Номенклатура = НоменклатураВыручки;
						Движение.ТипПремии = ПредопределенноеЗначение(
						"Перечисление.РА_ТипыПремийПартнерам.ПремияЗаФорматОтгрузки");
						Движение.ПроцентПремии = СтрокаПоФорматуОтгрузки.ПроцентПремии;
						Движение.СуммаВыручки = СтрокаДвиженияВыручка.СуммаВыручкиРегл;
						Движение.Сумма = СтрокаДвиженияВыручка.СуммаВыручкиРегл * СтрокаПоФорматуОтгрузки.ПроцентПремии
							/ 100;

					КонецЕсли;

				КонецЦикла;

			КонецЦикла;

		КонецЕсли;

#КонецОбласти

#Область РасчетБонусовЗаПредоставлениеСтатистическихДанных

		Если ДействующаяПрограммаБонуса.ПроцентПремииЗаСтатистическиеДанныеДанные <> 0 Тогда

			Для Каждого СтрокаДвиженияВыручка Из ДвиженияПоВыручке Цикл

				Если СтрокаДвиженияВыручка.РасчетСебестоимости Тогда
					Продолжить;
				КонецЕсли;

				Если РеквизитИсключитьИзБонусаСуществует И ЗаказИсключаетсяИзБонусов(
					СтрокаДвиженияВыручка.ЗаказКлиента) Тогда
					Продолжить;
				КонецЕсли;

				НоменклатураВыручки = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
					СтрокаДвиженияВыручка.АналитикаУчетаНоменклатуры, "Номенклатура");

				РеквизитыНоменклатуры = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(НоменклатураВыручки,
					"Производитель, РА_ВходитВБазуБонусовПриЗакупках");

				Если МассивПодходящейНоменклатуры.Найти(НоменклатураВыручки) <> Неопределено
					И РеквизитыНоменклатуры.РА_ВходитВБазуБонусовПриЗакупках Тогда

					Движение = Движения.РА_ПодсистемаРасчетаБонусовПартнеров_БонусыПартнерам.ДобавитьПриход();
					Движение.Период = СтрокаДвиженияВыручка.Период;
					Движение.Активность = Истина;

					Движение.АналитикаУчетаБонуснойПрограммы = ДействующаяПрограммаБонуса.БонуснаяПрограммаСсылка;

					Движение.Номенклатура = НоменклатураВыручки;
					Движение.ТипПремии = ПредопределенноеЗначение(
						"Перечисление.РА_ТипыПремийПартнерам.ПремияЗаПредоставлениеСтатистическихДанных");
					Движение.ПроцентПремии = ДействующаяПрограммаБонуса.ПроцентПремииЗаСтатистическиеДанныеДанные;
					Движение.СуммаВыручки = СтрокаДвиженияВыручка.СуммаВыручкиРегл;
					Движение.Сумма = СтрокаДвиженияВыручка.СуммаВыручкиРегл
						* ДействующаяПрограммаБонуса.ПроцентПремииЗаСтатистическиеДанныеДанные / 100;

				КонецЕсли;

			КонецЦикла;

		КонецЕсли;

#КонецОбласти

#Область РасчетБонусовЗаПредоплату

		Если ЭтоПредоплатныйДоговор(Договор) И ДействующаяПрограммаБонуса.ПроцентПремииЗаПредоплату <> 0 Тогда

			Для Каждого СтрокаДвиженияВыручка Из ДвиженияПоВыручке Цикл

				Если СтрокаДвиженияВыручка.РасчетСебестоимости Тогда
					Продолжить;
				КонецЕсли;

				Если РеквизитИсключитьИзБонусаСуществует И ЗаказИсключаетсяИзБонусов(
					СтрокаДвиженияВыручка.ЗаказКлиента) Тогда
					Продолжить;
				КонецЕсли;

				НоменклатураВыручки = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
					СтрокаДвиженияВыручка.АналитикаУчетаНоменклатуры, "Номенклатура");

				РеквизитыНоменклатуры = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(НоменклатураВыручки,
					"Производитель, РА_ВходитВБазуБонусовПриЗакупках");

				Если МассивПодходящейНоменклатуры.Найти(НоменклатураВыручки) <> Неопределено
					И РеквизитыНоменклатуры.РА_ВходитВБазуБонусовПриЗакупках Тогда

					Движение = Движения.РА_ПодсистемаРасчетаБонусовПартнеров_БонусыПартнерам.ДобавитьПриход();
					Движение.Период = СтрокаДвиженияВыручка.Период;
					Движение.Активность = Истина;

					Движение.АналитикаУчетаБонуснойПрограммы = ДействующаяПрограммаБонуса.БонуснаяПрограммаСсылка;

					Движение.Номенклатура = НоменклатураВыручки;
					Движение.ТипПремии = ПредопределенноеЗначение(
						"Перечисление.РА_ТипыПремийПартнерам.ПремияЗаПредоплату");
					Движение.ПроцентПремии = ДействующаяПрограммаБонуса.ПроцентПремииЗаПредоплату;
					Движение.СуммаВыручки = СтрокаДвиженияВыручка.СуммаВыручкиРегл;
					Движение.Сумма = СтрокаДвиженияВыручка.СуммаВыручкиРегл
						* ДействующаяПрограммаБонуса.ПроцентПремииЗаПредоплату / 100;

				КонецЕсли;

			КонецЦикла;

		КонецЕсли;

#КонецОбласти
	
	КонецЦикла;	
	
КонецПроцедуры

Функция ПолучитьДействующиеБонусныеПрограммы(ОбъектНастройки, Дата)
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РА_НастройкиНачисленияБонусовПартнерам.Ссылка КАК БонуснаяПрограммаСсылка,
	|	РА_НастройкиНачисленияБонусовПартнерам.Владелец КАК ОбъектНастройки,
	|	РА_НастройкиНачисленияБонусовПартнерам.ПериодДействия КАК ПериодДействия,
	|	РА_НастройкиНачисленияБонусовПартнерам.ТипПоказателяПлана КАК ТипПоказателяПлана,
	|	РА_НастройкиНачисленияБонусовПартнерам.Валюта КАК Валюта,
	|	РА_НастройкиНачисленияБонусовПартнерам.ПоказательПлана КАК ПоказательПлана,
	|	РА_НастройкиНачисленияБонусовПартнерам.ПроцентПремииЗаПланЗакупок КАК ПроцентПремииЗаПланЗакупок,
	|	РА_НастройкиНачисленияБонусовПартнерам.ПроцентПремииЗаШоуРум КАК ПроцентПремииЗаШоуРум,
	|	РА_НастройкиНачисленияБонусовПартнерам.ПроцентПремииЗаСложныйПродукт КАК ПроцентПремииЗаСложныйПродукт,
	|	РА_НастройкиНачисленияБонусовПартнерам.ПроцентПремииЗаСтатистическиеДанныеДанные,
	|	РА_НастройкиНачисленияБонусовПартнерам.ПроцентПремииЗаПредоплату,
	|	РА_НастройкиНачисленияБонусовПартнерам.Производители.(
	|		Производитель КАК Производитель) КАК Производители,
	|	РА_НастройкиНачисленияБонусовПартнерам.ДополнительнаяНоменклатура.(
	|		Номенклатура КАК Номенклатура) КАК ДополнительнаяНоменклатура,
	|	РА_НастройкиНачисленияБонусовПартнерам.НастройкиПремийПоФорматамОтгрузки.(
	|		ФорматОтгрузки КАК ФорматОтгрузки,
	|		ПроцентПремии КАК ПроцентПремии) КАК НастройкиПремийПоФорматамОтгрузки,
	|	РА_НастройкиНачисленияБонусовПартнерам.НастройкиПремийПоВидамОборудования.(
	|		ВидОборудования КАК ВидОборудования,
	|		ПроцентПремии КАК ПроцентПремии,
	|		ТипПоказателя КАК ТипПоказателя,
	|		Показатель КАК Показатель) КАК НастройкиПремийПоВидамОборудования
	|ИЗ
	|	Справочник.РА_ПодсистемаРасчетаБонусовПартнеров_БонусныеПрограммы КАК РА_НастройкиНачисленияБонусовПартнерам
	|ГДЕ
	|	РА_НастройкиНачисленияБонусовПартнерам.Владелец = &ОбъектНастройки
	|	И РА_НастройкиНачисленияБонусовПартнерам.ПериодДействия.НачалоПериода <= &Дата
	|	И РА_НастройкиНачисленияБонусовПартнерам.ПериодДействия.КонецПериода >= &Дата
	|	И НЕ РА_НастройкиНачисленияБонусовПартнерам.ПометкаУдаления
	|	И ВЫБОР
	|		КОГДА РА_НастройкиНачисленияБонусовПартнерам.ДатаДосрочногоЗавершения = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ РА_НастройкиНачисленияБонусовПартнерам.ДатаДосрочногоЗавершения >= &Дата
	|	КОНЕЦ";
	
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("ОбъектНастройки", ОбъектНастройки);
	
	ТаблицаБонусныхПрограмм = Запрос.Выполнить().Выгрузить();
	
	Возврат ТаблицаБонусныхПрограмм;
	
КонецФункции	

// Заказ исключается из бонусов.
// 
// Параметры:
//  ЗаказКлиента - ДокументСсылка.ЗаказКлиента - Заказ клиента
// 
// Возвращаемое значение:
//  Произвольный - Заказ исключается из бонусов
Функция ЗаказИсключаетсяИзБонусов(ЗаказКлиента)
	//@skip-check wrong-string-literal-content
	Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ЗаказКлиента, "ИсключитьИзБонуса"); 
КонецФункции

// Формат отгрузки заказа.
// 
// Параметры:
//  ЗаказКлиента - ДокументСсылка.ЗаказКлиента - Заказ клиента
// 
// Возвращаемое значение:
//  СправочникСсылка.РА_ПодсистемаРасчетаБонусовПартнеров_ФорматыОтгрузки - Формат отгрузки заказа
Функция ФорматОтгрузкиЗаказа(ЗаказКлиента)
	//@skip-check wrong-string-literal-content
	Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ЗаказКлиента, "РА_ПодсистемаРасчетаБонусовПартнеров_ФорматОтгрузки"); 
КонецФункции	

Процедура СформироватьНачисленияБонусовКлиентам() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ИмяСобытияДляЖурналаРегистрации = "Формирование документов ""Начисление бонусов партнерам"" (Vaillant)";
	
	//Получим настройки форирования документов
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РА_НастройкиАвтоматическогоФормированияНачисленияБонусовПартнерам.ПериодичностьФормирования КАК ПериодичностьФормирования,
	|	РА_НастройкиАвтоматическогоФормированияНачисленияБонусовПартнерам.ОбновлятьРанееСозданныеДокументы КАК ОбновлятьРанееСозданныеДокументы,
	|	РА_НастройкиАвтоматическогоФормированияНачисленияБонусовПартнерам.УчетнаяЗаписьДляРассылки КАК УчетнаяЗаписьДляРассылки
	|ИЗ
	|	РегистрСведений.РА_НастройкиАвтоматическогоФормированияНачисленияБонусовПартнерам КАК РА_НастройкиАвтоматическогоФормированияНачисленияБонусовПартнерам";
	
	НастройкиФормирования = Запрос.Выполнить().Выгрузить();
	
	Если НастройкиФормирования.Количество() = 0 Тогда
		
		ЖурналРегистрации.ДобавитьСообщениеДляЖурналаРегистрации(ИмяСобытияДляЖурналаРегистрации,
		УровеньЖурналаРегистрации.Ошибка,,, "Настройки автоматического формирования документов ""Начисление бонусов партнерам"" не заданы! Выполнение невозможно!");
		
		Возврат;
	КонецЕсли;
	
	НастройкиФормирования = НастройкиФормирования[0];
	
	Если НастройкиФормирования.ПериодичностьФормирования = ПредопределенноеЗначение("Перечисление.РА_ПериодичностьАвтоматическогоФормированияНачисленияБонусовПартнерам.ЗаПредыдущийМесяц") Тогда
		ОперативнаяДата = НачалоДня(КонецМесяца(ДобавитьМесяц(ТекущаяДатаСеанса(),-1)));
	Иначе
		ОперативнаяДата = НачалоДня(КонецМесяца(ТекущаяДатаСеанса()));
	КонецЕсли;
	
	ОтправлятьРассылку = ЗначениеЗаполнено(НастройкиФормирования.УчетнаяЗаписьДляРассылки);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВЫРАЗИТЬ(ВЫБОР
	|		КОГДА ТИПЗНАЧЕНИЯ(РА_НастройкиНачисленияБонусовПартнерам.Владелец) = ТИП(Справочник.Партнеры)
	|			ТОГДА РА_НастройкиНачисленияБонусовПартнерам.Владелец
	|		ИНАЧЕ РА_НастройкиНачисленияБонусовПартнерам.Партнер
	|	КОНЕЦ КАК Справочник.Партнеры).ОсновнойМенеджер КАК ОсновнойМенеджер,
	|	ВЫРАЗИТЬ(ВЫБОР
	|		КОГДА ТИПЗНАЧЕНИЯ(РА_НастройкиНачисленияБонусовПартнерам.Владелец) = ТИП(Справочник.Партнеры)
	|			ТОГДА РА_НастройкиНачисленияБонусовПартнерам.Владелец
	|		ИНАЧЕ РА_НастройкиНачисленияБонусовПартнерам.Партнер
	|	КОНЕЦ КАК Справочник.Партнеры).РА_ПодсистемаРасчетаБонусовПартнеров_Контролирует КАК Контролирует,
	|	ВЫБОР
	|		КОГДА ТИПЗНАЧЕНИЯ(РА_НастройкиНачисленияБонусовПартнерам.Владелец) = ТИП(Справочник.Партнеры)
	|			ТОГДА РА_НастройкиНачисленияБонусовПартнерам.Владелец
	|		ИНАЧЕ РА_НастройкиНачисленияБонусовПартнерам.Партнер
	|	КОНЕЦ КАК Партнер,
	|	РА_НастройкиНачисленияБонусовПартнерам.Владелец КАК ОбъектНастройки,
	|	РА_НастройкиНачисленияБонусовПартнерам.ПериодДействия КАК ПериодДействия,
	|	ВЫБОР
	|		КОГДА ТИПЗНАЧЕНИЯ(РА_НастройкиНачисленияБонусовПартнерам.Владелец) = ТИП(Справочник.ДоговорыКонтрагентов)
	|			ТОГДА РА_НастройкиНачисленияБонусовПартнерам.Владелец
	|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.ДоговорыКонтрагентов.ПустаяСсылка)
	|	КОНЕЦ КАК Договор,
	|	ЕСТЬNULL(РА_НачислениеБонусовПартнерам.Ссылка,
	|		ЗНАЧЕНИЕ(Документ.РА_ПодсистемаРасчетаБонусовПартнеров_НачислениеБонусовПартнерам.ПустаяСсылка)) КАК
	|		ДокументНачисление,
	|	ЕСТЬNULL(РА_НачислениеБонусовПартнерам.НеИзменятьАвтоматически, ЛОЖЬ) КАК НеИзменятьАвтоматически,
	|	(ВЫБОР
	|		КОГДА ТИПЗНАЧЕНИЯ(РА_НастройкиНачисленияБонусовПартнерам.ОбъектНастройки) = ТИП(Справочник.Партнеры)
	|			ТОГДА РА_НастройкиНачисленияБонусовПартнерам.Владелец
	|		ИНАЧЕ РА_НастройкиНачисленияБонусовПартнерам.Партнер
	|	КОНЕЦ).Наименование КАК ПартнерНаименование,
	|	(ВЫБОР
	|		КОГДА ТИПЗНАЧЕНИЯ(РА_НастройкиНачисленияБонусовПартнерам.ОбъектНастройки) = ТИП(Справочник.ДоговорыКонтрагентов)
	|			ТОГДА РА_НастройкиНачисленияБонусовПартнерам.ОбъектНастройки
	|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.ДоговорыКонтрагентов.ПустаяСсылка)
	|	КОНЕЦ).Наименование КАК ДоговорНаименование
	|ИЗ
	|	Справочник.РА_ПодсистемаРасчетаБонусовПартнеров_БонусныеПрограммы КАК РА_НастройкиНачисленияБонусовПартнерам
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РА_ПодсистемаРасчетаБонусовПартнеров_НачислениеБонусовПартнерам КАК
	|			РА_НачислениеБонусовПартнерам
	|		ПО (ВЫБОР
	|			КОГДА ТИПЗНАЧЕНИЯ(РА_НастройкиНачисленияБонусовПартнерам.Владелец) = ТИП(Справочник.Партнеры)
	|				ТОГДА РА_НастройкиНачисленияБонусовПартнерам.Владелец
	|			ИНАЧЕ РА_НастройкиНачисленияБонусовПартнерам.Партнер
	|		КОНЕЦ = РА_НачислениеБонусовПартнерам.Партнер)
	|		И (ВЫБОР
	|			КОГДА ТИПЗНАЧЕНИЯ(РА_НастройкиНачисленияБонусовПартнерам.Владелец) = ТИП(Справочник.ДоговорыКонтрагентов)
	|				ТОГДА РА_НастройкиНачисленияБонусовПартнерам.Владелец
	|			ИНАЧЕ ЗНАЧЕНИЕ(Справочник.ДоговорыКонтрагентов.ПустаяСсылка)
	|		КОНЕЦ = РА_НачислениеБонусовПартнерам.Договор)
	|		И РА_НастройкиНачисленияБонусовПартнерам.ПериодДействия = РА_НачислениеБонусовПартнерам.ПериодДействия
	|		И (НЕ РА_НачислениеБонусовПартнерам.ПометкаУдаления)
	|ГДЕ
	|	РА_НастройкиНачисленияБонусовПартнерам.ПериодДействия.КонецПериода = &ОперативнаяДата
	|	И НЕ ЕСТЬNULL(РА_НачислениеБонусовПартнерам.НеИзменятьАвтоматически, ЛОЖЬ)
	|	И ВЫБОР
	|		КОГДА &ОбновлятьРанееСозданныеДокументы
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЕСТЬNULL(РА_НачислениеБонусовПартнерам.Ссылка,
	|			ЗНАЧЕНИЕ(Документ.РА_ПодсистемаРасчетаБонусовПартнеров_НачислениеБонусовПартнерам.ПустаяСсылка)) = ЗНАЧЕНИЕ(Документ.РА_ПодсистемаРасчетаБонусовПартнеров_НачислениеБонусовПартнерам.ПустаяСсылка)
	|	КОНЕЦ
	|ИТОГИ
	|ПО
	|	ОсновнойМенеджер,
	|	Контролирует";
	
	Запрос.УстановитьПараметр("ОперативнаяДата", ОперативнаяДата);
	Запрос.УстановитьПараметр("ОбновлятьРанееСозданныеДокументы", НастройкиФормирования.ОбновлятьРанееСозданныеДокументы);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаОсновнойМенеджер = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаОсновнойМенеджер.Следующий() Цикл
		
		ВыборкаРА_Контролирует = ВыборкаОсновнойМенеджер.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				
		Пока ВыборкаРА_Контролирует.Следующий() Цикл
			
			Если ОтправлятьРассылку Тогда
				
				ТабличныйДокументРезультат = Новый ТабличныйДокумент;
				ТабличныйДокументРезультат.АвтоМасштаб = Истина;
				
				Макет = ПолучитьОбщийМакет("MXL_ШаблонПрисоединенногоФайлаНачислениеБонусов");
				
				ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
				
				ОбластьШапка.Параметры.Ответственный = ВыборкаРА_Контролирует.ОсновнойМенеджер;
				ОбластьШапка.Параметры.Контролирует = ВыборкаРА_Контролирует.Контролирует;
				ОбластьШапка.Параметры.ДатаВыполнения = Формат(ТекущаяДатаСеанса(),"ДФ='dd.MM.yyyy ""г.""'");
				
				ТабличныйДокументРезультат.Вывести(ОбластьШапка);
				ТабличныйДокументРезультат.Вывести(Макет.ПолучитьОбласть("ШапкаТаблицы"));
				
			КонецЕсли;
			
			ВыборкаДетальныеЗаписи = ВыборкаРА_Контролирует.Выбрать();
			
			Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
				
				Если ВыборкаДетальныеЗаписи.НеИзменятьАвтоматически Тогда 
					Продолжить;
				КонецЕсли;
								
				Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДокументНачисление) Тогда
					ДокументОбъект = ВыборкаДетальныеЗаписи.ДокументНачисление.ПолучитьОбъект();
					ЭтоНовыйДокумент = Ложь;
				Иначе
					ДокументОбъект = Документы.РА_ПодсистемаРасчетаБонусовПартнеров_НачислениеБонусовПартнерам.СоздатьДокумент();
					ЭтоНовыйДокумент = Истина;
				КонецЕсли;	
				
				ДокументОбъект.Дата = КонецМесяца(ОперативнаяДата);
				
				ЗаполнитьЗначенияСвойств(ДокументОбъект, ВыборкаДетальныеЗаписи); 
				
				Если ЗначениеЗаполнено(ДокументОбъект.Договор) Тогда
					ДокументОбъект.Контрагент = 
					ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументОбъект.Договор, "Контрагент");
				Иначе
					
					Запрос = Новый Запрос;
					Запрос.Текст = 
					"ВЫБРАТЬ
					|	Контрагенты.Ссылка КАК Ссылка
					|ИЗ
					|	Справочник.Контрагенты КАК Контрагенты
					|ГДЕ
					|	Контрагенты.Партнер = &Партнер";
					
					Запрос.УстановитьПараметр("Партнер", ДокументОбъект.Партнер);
					
					//@skip-check query-in-loop
					ЗапросКонтрагент = Запрос.Выполнить().Выгрузить();
					
					Если ЗапросКонтрагент.Количество() = 1 Тогда
						ДокументОбъект.Контрагент = ЗапросКонтрагент[0].Ссылка;
					КонецЕсли;	
					
				КонецЕсли;
				
				Если ЗначениеЗаполнено(ДокументОбъект.Договор) Тогда
					ДокументОбъект.Организация = 
					ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументОбъект.Договор, "Организация");
				Иначе
					
					Запрос = Новый Запрос;
					Запрос.Текст = 
					"ВЫБРАТЬ
					|	Организации.Ссылка КАК Ссылка
					|ИЗ
					|	Справочник.Организации КАК Организации
					|ГДЕ
					|	Организации.Наименование <> ""Управленческая организация""";
		
					//@skip-check query-in-loop
					ЗапросОрганизация= Запрос.Выполнить().Выгрузить();
					
					Если ЗапросОрганизация.Количество() = 1 Тогда
						ДокументОбъект.Организация = ЗапросОрганизация[0].Ссылка;
					КонецЕсли;	
					
				КонецЕсли;
				
				ДокументОбъект.ПолучитьДоступныеБонусныеПрограммы();
				ДокументОбъект.ЗаполнитьАвтоматическийРасчет();
				
				Попытка
					ОписаниеОшибки = "";
					ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
				Исключение
					ОписаниеОшибки = ОписаниеОшибки();
					ДокументОбъект.Записать(РежимЗаписиДокумента.Запись);
				КонецПопытки;	
				
				Если ОтправлятьРассылку Тогда
														
					ОбластьСтрока = Макет.ПолучитьОбласть("СтрокаТаблицы");
					ОбластьСтрока.Параметры.НомерДокумента = ДокументОбъект.Номер;
					ОбластьСтрока.Параметры.ДатаДокумента = Формат(ДокументОбъект.Дата,"ДФ=dd.MM.yyyy");
					ОбластьСтрока.Параметры.Партнер = ВыборкаДетальныеЗаписи.ПартнерНаименование;
					ОбластьСтрока.Параметры.Договор = ВыборкаДетальныеЗаписи.ДоговорНаименование;
					ОбластьСтрока.Параметры.СсылкаНаДокумент = ПолучитьНавигационнуюСсылку(ДокументОбъект.Ссылка);
					
					Если ЗначениеЗаполнено(ОписаниеОшибки) Тогда
						ТекстОписания = ОписаниеОшибки;
					ИначеЕсли ЭтоНовыйДокумент Тогда
						ТекстОписания = "Создан новый документ.";
					ИначеЕсли НЕ ЭтоНовыйДокумент Тогда	
						ТекстОписания = "Документ обновлен.";
					КонецЕсли;	
					
					ОбластьСтрока.Параметры.Описание = ТекстОписания;
					
					ТабличныйДокументРезультат.Вывести(ОбластьСтрока);
				КонецЕсли;
								
			КонецЦикла;
			
			Если ОтправлятьРассылку Тогда
				
				ИмяФайла = ПолучитьИмяВременногоФайла(".xlsx");
				
				ТабличныйДокументРезультат.Записать(ИмяФайла, ТипФайлаТабличногоДокумента.XLSX);
				
				КИ_ОсновнойМенеджер = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(
				ВыборкаРА_Контролирует.ОсновнойМенеджер, Справочники.ВидыКонтактнойИнформации.EmailПользователя, ТекущаяДатаСеанса(), Истина);
				
				КИ_Контролирует = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(
				ВыборкаРА_Контролирует.Контролирует, Справочники.ВидыКонтактнойИнформации.EmailПользователя, ТекущаяДатаСеанса(), Истина);
				
				ПараметрыПисьма = Новый Структура;
				
				Если ЗначениеЗаполнено(КИ_ОсновнойМенеджер) Тогда
					ОсновнойПолучатель = КИ_ОсновнойМенеджер;
				ИначеЕсли ЗначениеЗаполнено(КИ_Контролирует) Тогда
					ОсновнойПолучатель = КИ_Контролирует;
				Иначе
					
					ЖурналРегистрации.ДобавитьСообщениеДляЖурналаРегистрации(ИмяСобытияДляЖурналаРегистрации,
					УровеньЖурналаРегистрации.Ошибка,,, "Почтовые адреса для: " + ВыборкаРА_Контролирует.ОсновнойМенеджер + " и " + ВыборкаРА_Контролирует.Контролирует + " не указаны. Отправка письма невозможна!");
					
					Продолжить;
				КонецЕсли;
				
				ПараметрыПисьма.Вставить("Кому", ОсновнойПолучатель);
				
				Если ЗначениеЗаполнено(КИ_Контролирует) И (КИ_Контролирует <> ОсновнойПолучатель) Тогда
					ПараметрыПисьма.Вставить("Копии", КИ_Контролирует);	
				КонецЕсли;	
				
				ПараметрыПисьма.Вставить("Тема", "Автоматическое создание документов ""Начисление бонусов партнерам""");
				ПараметрыПисьма.Вставить("Тело", "Данное письмо сгенерировано автоматически из 1С. Отвечать на него не нужно.");
				ПараметрыПисьма.Вставить("Важность", ВажностьИнтернетПочтовогоСообщения.Высокая); 
				
				Вложение = Новый Структура;
				Вложение.Вставить("АдресВоВременномХранилище", Новый ДвоичныеДанные(ИмяФайла));
				Вложение.Вставить("Представление", "Результат формирования.xlsx");
				
				ПараметрыПисьма.Вставить("Вложения", ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Вложение));
				ПараметрыПисьма.Вставить("ТипТекста", Перечисления.ТипыТекстовЭлектронныхПисем.ПростойТекст);
				
				ПараметрыПисьма.Вставить("ИмяОтправителя","");
				ПараметрыПисьма.Вставить("Отправитель", Новый Структура("ОтображаемоеИмя, Адрес"));
				ПараметрыПисьма.Вставить("АдресаУведомленияОПрочтении", Неопределено);
				ПараметрыПисьма.Вставить("ОбратныйАдрес", Неопределено);
				ПараметрыПисьма.Вставить("Получатели", Неопределено);
				ПараметрыПисьма.Вставить("СлепыеКопии", Неопределено);
				
				Письмо = РаботаСПочтовымиСообщениями.ПодготовитьПисьмо(НастройкиФормирования.УчетнаяЗаписьДляРассылки, ПараметрыПисьма);
				
				РаботаСПочтовымиСообщениями.ОтправитьПисьмо(НастройкиФормирования.УчетнаяЗаписьДляРассылки, Письмо);
				
				УдалитьФайлы(ИмяФайла);
				
			КонецЕсли;
			
		КонецЦикла;
	КонецЦикла;
    
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

// Получить массив номенклатуры для расчетм бонусов по плану закупок.
// 
// Параметры:
//  МассивПроизводителей - Массив из СправочникСсылка.Производители
//  МассивДополнительнойНоменклатуры - Массив из СправочникСсылка.Номенклатура
// 
// Возвращаемое значение:
// Массив из СправочникСсылка.Производители 
Функция ПолучитьМассивНоменклатурыДляРасчетаБонусовПоПлануЗакупок(МассивПроизводителей, МассивДополнительнойНоменклатуры)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВложенныйЗапрос.Ссылка КАК Ссылка
		|ИЗ
		|	(ВЫБРАТЬ
		|		Номенклатура.Ссылка КАК Ссылка
		|	ИЗ
		|		Справочник.Номенклатура КАК Номенклатура
		|	ГДЕ
		|		ВЫБОР
		|			КОГДА &ОтборПоПроизводителю
		|				ТОГДА Номенклатура.Производитель В (&МассивПроизводителей)
		|			ИНАЧЕ ИСТИНА
		|		КОНЕЦ
		|
		|	ОБЪЕДИНИТЬ ВСЕ
		|
		|	ВЫБРАТЬ
		|		Номенклатура.Ссылка
		|	ИЗ
		|		Справочник.Номенклатура КАК Номенклатура
		|	ГДЕ
		|		Номенклатура.Ссылка В (&МассивНоменклатур)) КАК ВложенныйЗапрос
		|СГРУППИРОВАТЬ ПО
		|	ВложенныйЗапрос.Ссылка";
	
	Запрос.УстановитьПараметр("ОтборПоПроизводителю", МассивПроизводителей.Количество() > 0);
	Запрос.УстановитьПараметр("МассивПроизводителей", МассивПроизводителей);
	Запрос.УстановитьПараметр("МассивНоменклатур", МассивДополнительнойНоменклатуры);
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
КонецФункции

// Это предоплатный договор. Считаем, что если для договора не указан основной договор, то он является Предоплатным
// 
// Параметры:
//  Договор - СправочникСсылка.ДоговорыКонтрагентов
// 
// Возвращаемое значение:
// Булево 
Функция ЭтоПредоплатныйДоговор(Договор)

	ОсновнойДоговор = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор,
		"РА_ПодсистемаРасчетаБонусовПартнеров_ОсновнойДоговор");

	Возврат ОсновнойДоговор.Пустая();

КонецФункции		

#КонецОбласти	

