from bs4 import BeautifulSoup as bs 

simple_html = """
<html>

<head>
  <style>
    li {font-size: 18px;}
  </style
</head>

<body>
  <div style="border-style: dotted; padding: 10px">
    <h1>Today's Learning Objectives</h1>
    <ul>
      <li>Decipher basic HTML</li>
      <li>Retrieve information from Internet</li>
      <li>Parse web data</li>
      <li>Gather and prepare data systematically</li>
    </ul>
    <br>
  </div>
</body>

</html>
"""
workshop_html = """
<html>

<body>
  <h1>Today's Workshop</h1>
  <div id='agenda' style="background-color: aliceblue">
    <h2>Agenda</h2>
    <p>Today's workshop is comprised of three main sections:</p>
    <ol>
      <li>HTML Basics</li>
      <li>Scraping Basics</li>
      <li>Scraping Pipeline</li>
    </ol>
  </div>

  <div id='tools' style='background-color: honeydew'>
    <h2>Tools</h2>
    <p>You will be learning about two primary Python libraries:</p>
    <ol>
      <li>BeautifulSoup</li>
      <li>requests</li>
    </ol>
  </div>
</body>

</html>
"""

soup = bs(simple_html, features="html5lib")
print(soup.find('h1').text)
for i in soup.find_all('li'):
  print(i.text)


