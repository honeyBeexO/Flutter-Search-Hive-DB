import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'models/car.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter(CarAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MaterialApp(
        showSemanticsDebugger: false,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Hive Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox<Car>('cars'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: [
                  IconButton(
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: SearchWidget(),
                      );
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              extendBody: true,
              extendBodyBehindAppBar: true,
              body: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40.0),
                    Text(
                      'Register a new car',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const CarForm(),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: _buildListView(),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }

  ValueListenableBuilder _buildListView() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Car>('cars').listenable(),
      builder: (context, carsBox, _) {
        try {
          return ListView.builder(
            itemCount: (carsBox!).length,
            itemBuilder: (context, index) {
              final Car car = carsBox!.getAt(index);
              return Hero(
                tag: car.model,
                child: Card(
                  elevation: 3.0,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.network(
                      car.images.first,
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.contain,
                    ),
                    title: Text(car.model),
                    subtitle: Text(car.year.toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await carsBox!.putAt(
                              index,
                              Car(
                                model: car.model,
                                year: car.year + 1,
                                description: car.description,
                                images: car.images,
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                        const SizedBox(width: 16.0),
                        IconButton(
                          onPressed: () async {
                            await carsBox!.deleteAt(index);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CarDetails(car: car),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        } catch (e) {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class CarForm extends StatefulWidget {
  const CarForm({Key? key}) : super(key: key);

  @override
  _CarFormState createState() => _CarFormState();
}

class _CarFormState extends State<CarForm> {
  final _formKey = GlobalKey<FormState>();
  late String _model;
  late String _year;

  Future<void> addCar(Car car) async {
    final carsBox = Hive.box<Car>('cars');
    await carsBox.add(car).then(
          (value) => print(car.toString() + 'value: $value'),
        );
  }

  late TextEditingController _modelController, _yearController;
  @override
  void initState() {
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _formKey.currentState!.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _modelController,
            decoration: const InputDecoration(labelText: 'Model'),
            onSaved: (value) {
              _model = _modelController.value.text;
              _modelController.clear();
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _yearController,
            decoration: const InputDecoration(labelText: 'Year'),
            onSaved: (value) {
              // _year = value!;
              _year = _yearController.value.text;
              _yearController.clear();
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _formKey.currentState!.save();
              final _newCar = Car(
                model: _model,
                year: int.parse(_year),
                description: description,
                images: _model.toLowerCase().contains('bmw')
                    ? bmw
                    : _model.toLowerCase().contains('audi')
                        ? audi
                        : mercedes,
              );
              addCar(_newCar);
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

class CarDetails extends StatelessWidget {
  const CarDetails({
    Key? key,
    required this.car,
  }) : super(key: key);
  final Car car;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              CarImages(car: car),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  top: (20),
                ),
                padding: const EdgeInsets.only(
                  top: (20),
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: (20),
                    right: (64),
                  ),
                  child: Column(
                    children: [
                      Text(
                        car.model,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        car.year.toString(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        car.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: Colors.black),
                        maxLines: 4,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarImages extends StatefulWidget {
  const CarImages({
    Key? key,
    required this.car,
  }) : super(key: key);

  final Car car;

  @override
  _CarImagesState createState() => _CarImagesState();
}

class _CarImagesState extends State<CarImages> {
  int selectedImageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Hero(
          tag: widget.car.model,
          child: SizedBox(
            width: 256.0,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                widget.car.images[selectedImageIndex],
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              widget.car.images.length,
              (index) => InkWell(
                onTap: () {
                  setState(() {
                    selectedImageIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(
                    (8),
                  ),
                  margin: const EdgeInsets.only(right: 5),
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(
                      color: index == selectedImageIndex
                          ? Colors.black
                          : Colors.grey[200]!,
                      width: 2,
                    ),
                  ),
                  child: Image.network(
                    widget.car.images[index],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SearchWidget extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
      onPressed: () {
        close(context, null); // for closing the search page and going back
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Car>('cars').listenable(),
      builder: (context, Box<Car> carsBox, _) {
        var results = query.isEmpty
            ? carsBox.values.toList()
            : carsBox.values
                .where(
                  (car) => car.model.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
        return results.isEmpty
            ? Center(
                child: Text(
                  'No results found !',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Colors.black,
                      ),
                ),
              )
            : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final Car _car = results[index];
                  return ListTile(
                    leading: Image.network(
                      _car.images.first,
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    ),
                    title: Text(_car.model),
                    subtitle: Text(_car.year.toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarDetails(car: _car),
                        ),
                      );
                    },
                  );
                },
              );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Car>('cars').listenable(),
      builder: (context, Box<Car> carsBox, _) {
        var results = query.isEmpty
            ? carsBox.values.toList()
            : carsBox.values
                .where(
                  (car) => car.model.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
        return results.isEmpty
            ? Center(
                child: Text(
                  'No results found !',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Colors.black,
                      ),
                ),
              )
            : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final Car _car = results[index];
                  return ListTile(
                    leading: Image.network(
                      _car.images.first,
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    ),
                    title: Text(_car.model),
                    subtitle: Text(_car.year.toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarDetails(car: _car),
                        ),
                      );
                    },
                  );
                },
              );
      },
    );
  }
}

const List<String> bmw = [
  'https://images.unsplash.com/photo-1510903117032-f1596c327647?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1740&q=80',
  'https://images.unsplash.com/photo-1593284094481-503ee97959be?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2532&q=80',
  'https://images.unsplash.com/photo-1598560342586-54fac322e093?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=876&q=80',
  'https://images.unsplash.com/photo-1542906042-f41e62496963?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=830&q=80',
];
const List<String> audi = [
  'https://images.unsplash.com/photo-1493238792000-8113da705763?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1740&q=80',
  'https://images.unsplash.com/photo-1536150794560-43f988aec18e?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1742&q=80',
  'https://images.unsplash.com/photo-1615141850457-2a422b17e282?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=627&q=80'
      'https://images.unsplash.com/photo-1602837381509-65e2694efc1c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=930&q=80',
];
const List<String> mercedes = [
  'https://images.unsplash.com/photo-1489686995744-f47e995ffe61?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=930&q=80',
  'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=816&q=80',
  'https://images.unsplash.com/photo-1617814076231-2c58846db944?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=627&q=80',
  'https://images.unsplash.com/photo-1553440569-bcc63803a83d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1650&q=80',
];

const String description =
    "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth";
