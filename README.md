# EasyExport
Export data from Easynvest account

This is a simple script to export investment data from Easynvest to the CLI.
I've made this because I wanted to see just the total netvalue without taxes.

Data will be displayed like so:
~~~~
$ swift EasyExport.swift 
Fetching auth token...
Fetching investments...

* BANCO PINE S/A * 
Invested: R$1.000,00
NetValue: R$1.500,00
Profit: R$500,00
Index: 99% do CDI
Type: CDB

* BANCO ORIGINAL S/A * 
Invested: R$1.000,00
NetValue: R$1.500,00
Profit: R$500,00
Index: 95% do CDI 
Type: LCI

* ALASKA BLACK FIC FIA II * 
Invested: R$1.000,00
NetValue: R$1.500,00
Profit: R$500,00
Index: -- 
Type: --

Total NetValue: R$4.500,00
Total Profit: R$1.500,00
~~~~

To use this you'll need to get the `credentials` data from your account. 
One suggestion is to use [Charles](https://www.charlesproxy.com) and listen to the app login request.
