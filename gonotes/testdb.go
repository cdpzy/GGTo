package main

import (
	"fmt"
	"gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
	"time"
)

func main() {
	//url := "mogodb://root:123456@192.168.6.122:27017/players?--authenticationDatabase admin"

	info := &mgo.DialInfo{
		Addrs:    []string{"192.168.6.122"},
		Timeout:  60 * time.Second,
		Database: "players",
		Username: "root",
		Password: "123456",
		Source:   "admin",
	}

	session, err := mgo.DialWithInfo(info)
	//session, err := mgo.Dial(url)

	if nil != err {
		fmt.Println("failed to dail ", err)
		panic(err)
	}
	defer session.Close()

	session.SetMode(mgo.Monotonic, true)

	// *mgo.Collection
	playerinfo := session.DB("players").C("playerinfo")
	count := playerinfo.Find(bson.M{"name": "pzy"})
	fmt.Println("count is ", count)
}
