import requests
import re
from bs4 import BeautifulSoup as bs

url = 'https://en.wikipedia.org/wiki/Pennsylvania'
response = requests.get(url)
page=response.text
soup=bs(page,features="html5lib")
#print(soup.find(class_ = 'mw-disambig')['href'])
#print(soup.find(class_ = 'geo-dec').text)
first_table = soup.find('table').prettify()

state = soup.find('table').find('th').text
print(state)


admitted_regx = re.compile('Admitted')
admitted=soup.find(string=admitted_regx)
print(admitted.next.next)


