from bs4 import BeautifulSoup as bs
pycon_html = open('pycon_info.html').read()
pycon_soup = bs(pycon_html, features="html5lib")

today_div = pycon_soup.find(id='today')

# print([link['href'] for link in today_div.find_all('a')])

tomorrow_tuples = [(link.text, link['href']) for link in pycon_soup.find(id='tomorrow').find_all('a')]
print(tomorrow_tuples)

event_days = pycon_soup.find_all(class_ = 'events')

head_tags = [ day.find('h2').text for day in event_days ]
print(head_tags)
