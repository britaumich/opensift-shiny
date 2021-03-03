##must be run with sudo because of the iptables commands
declare -a arr=("35.1.0.0/16" "35.2.0.0/16" "35.3.0.0/16" "141.211.0.0/16" "10.211.128.0/22" "141.213.0.0/16")

for i in "${arr[@]}"
do
   echo "** updating to allow $i"
   iptables -I INPUT -s $i -p tcp --destination-port 27017 -m state --state NEW,ESTABLISHED -j ACCEPT
   iptables -I OUTPUT -d $i -p tcp --source-port 27017 -m state --state ESTABLISHED -j ACCEPT
done


for i in "${arr[@]}"
do
   echo "** updating to allow $i"
   iptables -I INPUT -s $i -p tcp --destination-port 3838 -m state --state NEW,ESTABLISHED -j ACCEPT
   iptables -I OUTPUT -d $i -p tcp --source-port 3838 -m state --state ESTABLISHED -j ACCEPT
done