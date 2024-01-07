import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // Implementing custom font
        fontFamily: "Roboto",

        // Changing appbar color
        appBarTheme: const AppBarTheme(color: Colors.red),

        // Changing background color
        scaffoldBackgroundColor: const Color(0xFFC00000),
        textTheme: const TextTheme(
          // titleLarge Text Style used for the appbar, feedback message, and alert dialogue titles
          titleLarge: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          // displayMedium Text Style used for alert dialogue content
          displayMedium: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      home: const MyHomePage(title: 'Project02 Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Text input controller
  final _inputTextController = TextEditingController();

  // Shared preferences variable to store search terms
  late SharedPreferences _preferences;

  // The url used to search for amiibos by name
  String nameURL = "https://amiiboapi.com/api/amiibo/?name=";

  // Search control variables
  String inputText = "";
  int results = 1;
  int columns = 1;

  // Feedback message variable
  String feedbackMessage = "Enter a search term to find an Amiibo!";

  // List which stores image url's returned by the API
  List<String> urlList = [];

  // Map which stores amiibo information returned by the API
  List<Map<String, dynamic>> infoMap = [];

  // Entries to populate the result dropdown control
  final resultCount = [
    const DropdownMenuItem(
      value: 1,
      child: Text("1"),
    ),
    const DropdownMenuItem(
      value: 2,
      child: Text("2"),
    ),
    const DropdownMenuItem(
      value: 3,
      child: Text("3"),
    ),
    const DropdownMenuItem(
      value: 4,
      child: Text("4"),
    ),
    const DropdownMenuItem(
      value: 5,
      child: Text("5"),
    ),
    const DropdownMenuItem(
      value: 10,
      child: Text("10"),
    ),
    const DropdownMenuItem(
      value: 20,
      child: Text("20"),
    ),
  ];

  // Entries to populate the column dropdown control
  final columnCount = [
    const DropdownMenuItem(
      value: 1,
      child: Text("1"),
    ),
    const DropdownMenuItem(
      value: 2,
      child: Text("2"),
    ),
    const DropdownMenuItem(
      value: 3,
      child: Text("3"),
    ),
    const DropdownMenuItem(
      value: 4,
      child: Text("4"),
    ),
  ];

  //Overriding the initState method to add a listener to the input controller and to call init method
  @override
  void initState() {
    super.initState();
    _inputTextController.addListener(() {
      setState(() {
        inputText = _inputTextController.text;
      });
    });
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gesturedetector which will minimize the keyboard when the user interacts with the page
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
        // ----- Appbar -----
        appBar: AppBar(
          title: Text(
            "Project02: Amiibo Finder",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          leading: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/amiibo-icon.png"))),
            ),
          ),
          // Info button which displays the documentation when clicked
          actions: [
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    "Documentation",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        // Documentation Text
                        Text(
                          "For the creation of this site, I started by creating a mockup of what I wanted the site to look like based on a previous project in IGME 330, which utilized the same API; this project can be found here: https://people.rit.edu/jjp1723/330/pionzio-p1/app.html. After creating this outline, I created a copy of Lab02: Gif Finder, and altered it to utilize the Amiibo API instead of the Giphy API. I accordingly altered the alert dialogue box the user sees upon clicking a a result to display relevant information about the amiibo(s). Once the functionality of the page was completed, I began to update the Overall design of the page, altering its overall format, changing colors and fonts, and polishing how it looked overall. I finished by going though all of the code I wrote and adding proper comments. I frequently made use of the class recordings while working on this site.\n\nThis site utilizes the Amiibo API, and allows the user to search for specific amiibos by the name of the character. To view additional information about an Amiibo, click on its image in the results section. The additional information for each amiibo includes its name, the amiibo series it is from, the game sereis it is from, its model number, and its release date in North America, Europe, Japan, and Australia. Additional controls provided to the user allow the user to change to total amount of results they wish to view and the amount of colums they want the results to be displayed in. Updating the amount of results will require the user to perform another search, but updating the amount of columns will update the results immediately.\n\nAmiibo Icon Source: http://videogames-fanon.wikia.com/wiki/File:Amiibo_icon.png\n\nFont Source: https://fonts.google.com/specimen/Roboto+Condensed\n\nCode Tutorials Utilized: https://www.youtube.com/@dowerchin\n\nOriginal Mockup:",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        // Mockup PNG
                        Container(
                          height: 320.0,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/project-2-mockup.PNG"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // "OK" Button closes the documentation alert dialogue
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    )
                  ],
                ),
              ),
              // Creating the icon itself
              icon: const Icon(
                Icons.info_outline,
                color: Colors.black,
              ),
            )
          ],
        ),

        // ----- Page Body -----

        // The entire page is scrollable just in case there is any overflow
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            // All page content is organized into a column
            child: Column(
              children: [
                // ----- Search Controls -----
                Container(
                  // Giving the container rounded corners
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E6E6),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                    child: Column(
                      children: [
                        // ----- Search Term Text Field -----
                        TextField(
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          controller: _inputTextController,
                          decoration: InputDecoration(
                            errorText: validateInput(_inputTextController.text),
                            border: const OutlineInputBorder(),
                            labelText: "Search Term",
                            contentPadding: const EdgeInsets.all(12.0),
                            fillColor: Colors.white,
                            filled: true,
                            suffixIcon: IconButton(
                              onPressed: () {
                                _inputTextController.clear();
                                inputText = "";
                              },
                              icon: const Icon(Icons.close_sharp),
                            ),
                          ),
                          // Pressing the enter key removes the keyboard
                          onSubmitted: (value) {
                            FocusScope.of(context).unfocus();
                            setState(
                              () {
                                inputText = value;
                              },
                            );
                          },
                        ),

                        // Sized Box creates additional spacing between the Search Term input and the dropdown dontrols
                        const SizedBox(
                          height: 16.0,
                        ),

                        // ----- Result Count Drop-Down -----
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                child: Center(
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      fillColor: Colors.white,
                                      labelText: "Result Count",
                                    ),
                                    value: results,
                                    items: resultCount,
                                    // Selecting a new value updates the 'results' variable
                                    onChanged: (newString) {
                                      setState(
                                        () {
                                          results = newString!;
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            // Sized Box creates additional spacing between the dropdown controls
                            const SizedBox(
                              width: 16.0,
                            ),

                            // ----- Column Count Drop-Down -----
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                child: Center(
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      fillColor: Colors.white,
                                      labelText: "# of Columns",
                                    ),
                                    value: columns,
                                    items: columnCount,
                                    // Selecting a new value updates the 'columns' variable
                                    onChanged: (newString) {
                                      setState(
                                        () {
                                          columns = newString!;
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ----- Button Controls -----
                Row(
                  children: [
                    // ----- Search Button -----
                    Expanded(
                      child: ElevatedButton(
                        // Pressing the button calls the 'getAmiibo' method
                        onPressed: getAmiibo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Find Some Amiibos!"),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // ----- Reset Button -----
                    Expanded(
                      child: ElevatedButton(
                        // Pressing the button calls the 'reset' method
                        onPressed: reset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Reset"),
                      ),
                    ),
                  ],
                ),

                // ----- Message Text to inform user of page state -----
                Center(
                  child: Text(
                    feedbackMessage,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                // ----- Grid of Resulting Amiibos -----
                Container(
                  // Giving the container rounded corners
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  height: 420,
                  // ----- Grid Builder -----
                  child: GridView.builder(
                    itemCount: results,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                    ),
                    // Adding items to the grid based on the list detailing items of the search results
                    itemBuilder: (context, index) {
                      if (index < urlList.length) {
                        return GridTile(
                          footer: const Center(),
                          // Each grid item displays an alert dialogue when clicked, detailing further information about the result itself
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  // The title of the alert is the name of the amiibo
                                  title: Text(
                                    "${infoMap[index]["character"]}",
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  // The content of the alert is a larger image of the amiibo and additional information regarding the amiibo's amiibo series, game series, model number, and release dates
                                  content: Column(
                                    children: [
                                      Image.network(urlList[index]),
                                      const SizedBox(
                                        height: 64.0,
                                      ),
                                      Text(
                                        "Amiibo Series:\t\t\t\t${infoMap[index]["amiiboSeries"]}\nGame Series:\t\t\t\t\t\t${infoMap[index]["gameSeries"]}\nModel Number:\t\t${infoMap[index]["modelNumberHead"]}${infoMap[index]["modelNumberTail"]}\n\nRelease Date (NA): ${infoMap[index]["releaseNA"]}\nRelease Date (EU): ${infoMap[index]["releaseEU"]}\nRelease Date (JP): ${infoMap[index]["releaseJP"]}\nRelease Date (AU): ${infoMap[index]["releaseAU"]}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium,
                                      )
                                    ],
                                  ),
                                  // Close button for closing the alert dialogue
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    )
                                  ],
                                ),
                              );
                            },
                            // Each result displays just the amiibos picture for simplicity
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6E6E6),
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                ),
                                child: Center(
                                  child: Image.network(urlList[index]),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----- validateInput Method -----
  String? validateInput(String value) {
    if (value == "") {
      return "Please enter a search term";
    }
    return null;
  }

  // ----- reset Method -----
  Future reset() async {
    // Resetting all variable to their default value
    _inputTextController.text = "";
    results = 1;
    columns = 1;
    feedbackMessage = "Enter a search term to find some Amiibos!";
    urlList = [];
    infoMap = [];

    // Calling the saveState method to update the sharedpreferences
    await saveState();
  }

  // ----- getAmiibo Method -----
  Future getAmiibo() async {
    // Updating the feedback message to inform user that a search is being performed
    setState(() {
      feedbackMessage = "Searching for \"$inputText\" Amiibos...";
    });

    // Waiting for a positive response from the API to continue
    var response = await http.get(Uri.parse(nameURL + inputText));
    if (response.statusCode == 200) {
      // Decoding response
      var jsonResponse = jsonDecode(response.body);

      // Setting the limit of images to be displayed
      if (jsonResponse["amiibo"].length != 0) {
        int limit = results;

        // If the limit the user imposed is less than the amount of items in the response, the limit is updated
        if (jsonResponse["amiibo"].length < results) {
          limit = jsonResponse["amiibo"].length;
        }

        // Changing the feedback to reflect the amount of results found
        if (limit == 1) {
          feedbackMessage = "1 \"$inputText\" Amiibo has been found!";
        } else {
          feedbackMessage = "$limit \"$inputText\" Amiibos have been found!";
        }

        // Clear the url list
        urlList = [];
        infoMap = [];

        setState(() {
          for (int index = 0; index < limit; index++) {
            // Adding the amiibo's image url to urlList
            urlList.add(jsonResponse["amiibo"][index]["image"]);
            // Adding the amiibo's information to the infoMap
            infoMap.add({
              "character": jsonResponse["amiibo"][index]["character"],
              "gameSeries": jsonResponse["amiibo"][index]["gameSeries"],
              "amiiboSeries": jsonResponse["amiibo"][index]["amiiboSeries"],
              "modelNumberHead": jsonResponse["amiibo"][index]["head"],
              "modelNumberTail": jsonResponse["amiibo"][index]["tail"],
              "releaseNA": jsonResponse["amiibo"][index]["release"]["na"],
              "releaseEU": jsonResponse["amiibo"][index]["release"]["eu"],
              "releaseJP": jsonResponse["amiibo"][index]["release"]["jp"],
              "releaseAU": jsonResponse["amiibo"][index]["release"]["au"]
            });
          }
        });

        // In case there was a positive response with no results
      } else {
        setState(() {
          feedbackMessage = "No results found for \"$inputText\"";
        });
      }

      // If the user failed to input any text before searching, the feebackMessage is updated accordingly
    } else if (inputText == "") {
      setState(() {
        feedbackMessage = "Please enter a search term before searching";
      });

      // If no results are found for the input search term, the feebackMessage is updated accordingly
    } else {
      setState(() {
        feedbackMessage = "No results found for \"$inputText\"";
        //feedbackMessage = "Error: ${response.statusCode}, ${response.reasonPhrase}";
      });
    }

    // Calling the saveState method to update the sharedpreferences
    await saveState();
  }

  // ----- init Method -----
  Future init() async {
    _preferences = await SharedPreferences.getInstance();

    // Loads any saved sharedpreferences
    _inputTextController.text = _preferences.getString("myInput") ?? "";
  }

  // ----- saveState Method -----
  Future saveState() async {
    _preferences.setString("myInput", _inputTextController.text);
  }
}
