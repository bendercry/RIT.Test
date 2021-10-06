# Общее описание
 
Необходимо создать реально работающую программу, которая выводит на экран текущую скорость и пройденную дистанцию в режиме Head Up Display (HUD).
При переводе приложения в режим HUD, смартфон должен ложиться под лобовое стекло автомобиля, так чтобы в отражении об лобовое стекло хорошо читались данные с экрана приложения.

# Функции приложения

- [x] Отображение скорости (задание 1)
- [x] отображение пройденной дистанции с момента запуска и среднюю скорость (задание 2) также нужно отображать кнопку сброса для пройденной дистанции и средней скорости средняя скорость должна показываться за последние 10 минут
- [x] отображение температуры на улице (задание 3)
- [x] включение режима HUD (задание 4) для контроля телефон в этом режиме надо класть под стекло и проверять что отражение читаемо и верно
- [x] получение скорости с GPS (задание 5)
- [x] установка миль/км (задание 6)
- [ ] сохранение последнего состояния приложения (задание 7) 
- [ ] отображение двух видов спидометров: аналоговый и цифровой (задание 8)

# P.S.
* Не нашел как пофиксить баг с тем, что при первом открытии приложения в симуляторе выдает ошибку **domain=kclerrordomain code=1 "(null)"** - везде пишут либо включить симуляцию в схеме проекта( у меня и так включено), либо перезагрузить симулятор. Перезагрузка симулятора это фиксит, но не решение проблемы, наверное
* Также не смог нормально протестировать как передается скорость, т.к. в симуляторе нельзя трекать скорость с симулированными локациями, только самостоятельно пытаться считать через пройденную дистанцию

<img width="355" alt="Screenshot 2021-10-06 at 16 53 46" src="https://user-images.githubusercontent.com/43619507/136206181-d8e4ca74-0a19-422e-8a22-1f0c1dfb3ddd.png">
<img width="347" alt="Screenshot 2021-10-06 at 16 53 34" src="https://user-images.githubusercontent.com/43619507/136206208-3559d04c-c06b-4b64-971e-77ff7173f9a1.png">
