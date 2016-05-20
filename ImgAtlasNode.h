#pragma once
#include "cocos2d.h"

USING_NS_CC;

class ImgAtlasNode : public CCNode
{
public:
	typedef std::map<int, std::string> ImgMap;
	typedef std::vector<std::string> ImgVec;
	typedef std::vector<int> CodeVec;

	static ImgMap makeImgMap(const std::string& , const ImgVec& aImgs);
	static CodeVec split(const std::string& aStr);

public:
	CREATE_FUNC(ImgAtlasNode);
	virtual bool init();

	void setImageMap(ImgMap& aImgMap);

	void setString(std::string aStr);

private:
	void spreadImgs();
	void clearImgs();

private:
	ImgMap mImgMap;
	std::vector<CCSprite*> mAllImgs;
};