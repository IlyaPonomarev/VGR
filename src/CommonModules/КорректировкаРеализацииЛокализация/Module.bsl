
#Область СлужебныеПРоцедурыИФункции

&После("ОбработкаПроведения")
Процедура РА_ПодсистемаРасчетаБонусовПартнеров_ОбработкаПроведения(Объект, Отказ, РежимПроведения)
	РА_ПодсистемаРасчетаБонусовПартнеров_РасчетБонусовСервер.ОбработатьНачислениеБонусов(Объект);
КонецПроцедуры

#КонецОбласти
