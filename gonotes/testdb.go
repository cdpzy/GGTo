package main

import (
	"fmt"
	"gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
	"time"
)

func main() {
	info := &mgo.DialInfo{
		Addrs:    []string{"192.168.6.122"},
		Timeout:  60 * time.Second,
		Database: "players",
		Username: "root",
		Password: "123456",
		Source:   "admin",
	}

	session, err := mgo.DialWithInfo(info)

	if nil != err {
		fmt.Println("failed to dail ", err)
		panic(err)
	}
	defer session.Close()

	// default mode is Strong, should use that.
	session.SetMode(mgo.Monotonic, true)

	// *mgo.Collection
	playerinfo := session.DB("players").C("playerinfo")
	count := playerinfo.Find(bson.M{"name": "pzy"})
	fmt.Println("count is ", count)
}
