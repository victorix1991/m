# Source  https://github.com/iam7cn/CN-IPTV
# Python 3.10
import re
import urllib3
#Get List
http = urllib3.PoolManager()
iptvs = http.request('GET','http://looktvepg.jsa.bcs.ottcn.com:8080/ysten-lvoms-epg/epg/getChannelIndexs.shtml?deviceGroupId=1697')
iptvd = iptvs.data.decode('utf-8')
#Parse the list
channel = re.findall('":{"uuid":"(.*?)","channelName":"(.*?)"', iptvd)
iptv_list_base = 'http://183.207.248.71:80/cntv/live1/'
#List append
iptv_list = []
for i in range(len(channel)):
    iptv_url = iptv_list_base + channel[i][1] + '/' + channel[i][0]
    iptv_list.append(iptv_url)
print(iptv_list)
