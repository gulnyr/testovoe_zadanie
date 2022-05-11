// импортируем необходимый набор пакетов
import 'dart:convert'; //JSON-декодер
import 'package:flutter/material.dart';
//as — указывает на то, что подключаемые методы из пакета будут доступны через объект-имя http (http.get, http.post и т.д.)
import 'package:http/http.dart' as http;
/*
Функция main - точка входа, выполнение приложения начинается с данной функции
runApp - для создания графического интерфейса, виджет в качестве параметра, т.е.: runApp(Widget app)
*/
void main() => runApp(MyApp());
//Класс MyApp наследуется от виджета StatelessWidget
class MyApp extends StatelessWidget { //StatelessWidget - не имеют состояния
  @override //Переопределение метода build
  Widget build(BuildContext context) { //Все виджеты наследуются от класса Widget. Функция build отвечает за построение иерархии виджетов
    return MaterialApp( //предназначен для создания графического интерфейса в стиле material design (дизайн-система)
      home: HomePage(), //это свойство принимает виджет в качестве объекта, отображаемого в маршруте приложения по умолчанию
    );
  }
}
//Создание класса для хранения данных
class ImageHundler {
  final String author; //final - константа, const в отличие от final доступно в момент компиляции
  final int width; //int - число
  final int height;
  final String download_url; //String - строка
  ImageHundler({
    required this.author, // делаем обязательным
    required this.width,
    required this.height,
    required this.download_url,
  });
}
class HomePage extends StatefulWidget { //StatefulWidget - имеет состояние
  @override //переопределяем метод createState()
  /*
  Создаем объект State с помощью метода createState, для возврата состояния.
  Нижнее подчеркивание _ используется для того, чтобы скрыть доступ к _HomePageState  из других файлов
  */
  _HomePageState createState() => _HomePageState();
}

//Применение запроса на получение
class _HomePageState extends State<HomePage> { //класс состояния унаследован от класса HomePage
/*
Future - для отложенной операции (представляет потенциальное значение или ошибку, которая будет доступна в будущем)
async помечается функция, исполняющая асинхронные операции через await
*/
  Future<List<ImageHundler>> getRequest() async {
    //Вставим URL
    String url = "https://picsum.photos/v2/list?limit=5";
    /*
    Открываем соединение Http и устанливаем заголовок запроса
    await позволяет дождаться выполнения асинхронной функции и после обработать результат, если он есть
    Извлекаем данные с помощью метода http.get(), возвращает Future, содержащий Response (Response содержит данные, полученные при успешном вызове http)
    */
    final response = await http.get(Uri.parse(url)); //await - сами асинхронные операции
    var responseData = json.decode(response.body); //JSON-декодер
    //Создание списка для хранения входных данных
    List<ImageHundler> imagegc = []; //Подготовим массив (список)
    for (var singleImage in responseData) { //создаем цикл for, разбираем responseData на части, с помощью новой переменной singleImage
      ImageHundler imagegcarray = ImageHundler( //определяем данные, для добавления в массив
          author: singleImage["author"],
          width: singleImage["width"],
          height: singleImage["height"],
          download_url: singleImage["download_url"]);

      //Добавление данных фото в массив
      imagegc.add(imagegcarray);
    }
    return imagegc; // возвращаем
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea( //может заполнить элементы управления, чтобы соответствовать экрану мобильного телефона
      child: Scaffold( //набор виджетов, которые визуально представляют собой пользовательский интерфейс (тулбар, меню, боковое меню и т.д.)
        appBar: AppBar( //верхняя навигация
          title: Text("Тестовое задание"), //виджет для текста
        ),
        body: Container( //виджет верстки, комбинация нескольких простых виджетов
          padding: EdgeInsets.all(16.0), //padding - отступ. EdgeInsets - определяет простанство, которое соответствует параметру padding
          child: FutureBuilder( //свойства дочерних виджетов
            future: getRequest(),
            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
              /*
              connectionState - указывает на текущее состояние соединения
              ConnectionState.done - если готово
              */
              if(snapshot.connectionState == ConnectionState.done) {
/*
snapshot.data?.length > 0 - условие, если количество наших данных в отрисовке больше 0.
ListView.builder - берет список дочерних элементов и делает из него список с возможностью прокрутки
 */
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  //оно равно количеству объектов в списке snapshot.data
                  //itemBuilder - для создания элементов в ListView
                  itemBuilder: (ctx, index) =>
                      ListTile( //ListTile - представляет строку фиксированной высоты
/*
onTap нажатие на элемент. После нажатия откроется второй экран DetailScreen, для него мы передаем данные, ссылка на фото: snapshot.data[index].download_url
Navigator.push() — метод который добавляет новый route в иерархию виджетов
MaterialPageRoute() — Модальный route, который заменяет весь экран адаптивным к платформе переходом анимации
builder — возвращает пользовательский интерфейс
 */
                        onTap: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (
                                context) => DetailScreen(
                                photoDetail: snapshot.data[index]
                                    .download_url))),
                        title: Text("Автор: " + snapshot.data[index].author +
                            "\n" + "Размер: " + "\n" + "Ширина: " +
                            "${snapshot.data[index].width}" + "\n" +
                            "Высота: " + "${snapshot.data[index].height}" +
                            "\n" + "Ссылка на скачивание: " + "${snapshot
                            .data[index].download_url}"),
                        contentPadding: EdgeInsets.only(bottom: 20.0),
                        leading: CircleAvatar( //просто круг, делает изображение круглым
                          radius: 30.0, //размер изображения
                          backgroundImage:
                          NetworkImage("${snapshot.data[index]
                              .download_url}"), //ссылка на изображение
                        ),
                      ),
                );
              }else{
                return CircularProgressIndicator();
              }//индикатор прогресса
            },
          ),
        ),
      ),
    );
  }

}
class DetailScreen extends StatelessWidget { //класс для второго экрана, полный размер изображения
  DetailScreen({@required this.photoDetail}); //пометить photoDetail как обязательное, чтобы передать какое-либо значение
  final photoDetail; //делаем константой
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector( //GestureDetector - обнаружение жестов
        child: Center(
          child: Hero( //чтобы делать плавную анимацию перехода между двумя маршрутами
            tag: 'imageHero', //если тег совпадает с тегом другого маршрута с которой перешли, то запустится анимация
            /*
            в photoDetail мы передали ссылку на оригинальное изображение.
            Передали таким образом: MaterialPageRoute(builder: (context) => DetailScreen(photoDetail: snapshot.data[index].download_url))
             */
            child: Image.network(photoDetail),
          ),
        ),
        onTap: () {
          Navigator.pop(context); //по клику в onTap, мы с помощью метода pop возвращаемся в предыдущий экран.
        },
      ),
    );
  }
}