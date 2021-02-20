import pandas as pd

file_name = 'police_killings.csv'
file_export_name = 'police_killings2.csv'
# Danh sách tên mới của các cột
coll_names = [
    'Name', 'Age', 'Gender', 'URL_image', 'Date', 'Street',
    'City', 'State', 'Zipcode', 'County', 'Agency_responsible',
    'Cause', 'Description', 'Status', 'Criminal_charges', 'URL_news',
    'Mental_illness', 'Unarmed', 'Weapon', 'Threat_level', 'Fleeing',
    'Body_camera', 'WaPo_ID', 'Off_duty', 'Geography', 'ID'
]
# Danh sách các cột muốn loại bỏ
removed_column = [
    'URL_image', 'Street', 'Zipcode', 'Description', 'URL_news',
    'Body_camera', 'WaPo_ID', 'ID'
]
# Danh sách các thuộc tính muốn thay thế
replace_list = {
    'AL':'Alabama',
    'AK':'Alaska',
    'AZ':'Arizona',
    'AR':'Arkansas',
    'CA':'California',
    'CO':'Colorado',
    'CT':'Connecticut',
    'DE':'Delaware',
    'DC':'Washington D.C.',
    'FL':'Florida',
    'GA':'Georgia',
    'HI':'Hawaii',
    'ID':'Idaho',
    'IL':'Illinois',
    'IN':'Indiana',
    'IA':'Iowa',
    'KS':'Kansas',
    'KY':'Kentucky',
    'LA':'Louisiana',
    'ME':'Maine',
    'MD':'Maryland',
    'MA':'Massachusetts',
    'MI':'Michigan',
    'MN':'Minnesota',
    'MS':'Mississippi',
    'MO':'Missouri',
    'MT':'Montana',
    'NE':'Nebraska',
    'NV':'Nevada',
    'NH':'New Hampshire',
    'NJ':'New Jersey',
    'NM':'New Mexico',
    'NY':'New York',
    'NC':'North Carolina',
    'ND':'North Dakota',
    'OH':'Ohio',
    'OK':'Oklahoma',
    'OR':'Oregon',
    'PA':'Pennsylvania',
    'RI':'Rhode Island',
    'SC':'South Carolina',
    'SD':'South Dakota',
    'TN':'Tennessee',
    'TX':'Texas',
    'US':'United States',
    'UT':'Utah',
    'VT':'Vermont',
    'VA':'Virginia',
    'WA':'Washington',
    'WV':'Virginia',
    'WI':'Wisconsin',
    'WY':'Wyoming',
    'AS':'American Samoa',
    'GU':'Guam',
    'MP':'Northern Mariana Islands',
    'PR':'Puerto Rico',
    'VI':'Virgin Islands'
    }
    
# Đọc file csv
df = pd.read_csv(file_name)
# Đổi tên các cột
df.columns = coll_names
# Loại bỏ những cột không cần thiết
df = df.drop(removed_column, axis = 1)
# Thay thế tên bang viết tắt thành tên đầy đủ
df = df.replace(replace_list)

# Chuẩn hóa cột Date
date = []
#    Ta tách Date thành các phần, ngày và tháng ta kiểm tra
#  xem có đủ 2 ký tự không
#    Sau đó ghép chúng lại theo định dạng YearMonthDay 
#  (ví dụ 20200101 chính là ngày 1/1/2020)
for i in range(len(df)):
    text = df.Date[i].split('/')
    if (len(text[0]) != 2):
        text[0] = '0' + text[0]
    if (len(text[1]) != 2):
        text[1] = '0' + text[1]
    date.append(text[2] + text[0] + text[1])
df.Date = date

# Xuất file CSV
df.to_csv(file_export_name, index = False)