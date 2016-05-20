
#include "ImgAtlasNode.h"

ImgMap ImgAtlasNode::makeImgMap(const std::string& aStr, const ImgVec& aImgs)
{
	ImgMap lRst;

	CodeVec lCodeVec = ImgAtlasNode::split(aStr);
	assert(lCodeVec.size() == aImgs.size());

	for (int i = 0; i < lCodeVec.size(); ++i) {
		lRst[lCodeVec[i]] = aImgs[i];
	}

	return lRst;
}

/// aStr ***MUST*** be encoded as valid ****UTF-8****
/// https://en.wikipedia.org/wiki/UTF-8
static const char trailingBytesForUTF8[256] = {
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 3,3,3,3,3,3,3,3,4,4,4,4,5,5,5,5
};
CodeVec ImgAtlasNode::split(const std::string& aStr)
{
	CodeVec lRst;

	int lCode = 0;
	for (auto i = 0; i < aStr.size();)
	{
		lCode = 0;
		auto lChar = aStr.at(i);
		auto lTrailingLen = trailingBytesForUTF8[lChar] + 1;
		for (auto j = 0; j < lTrailingLen; ++j) 
		{
			lCode += aStr.at(i + j);
		}
		lRst.push_back(lCode);
		i += lTrailingLen;
	}
}


bool ImgAtlasNode::init()
{
	if (!CCNode::init()) return false;
	return true;
}

void ImgAtlasNode::setImageMap(ImgMap& aImgMap)
{
	mAllImgs = aImgMap;
	clearImgs();
}

void ImgAtlasNode::clearImgs()
{
	for (auto spr : mAllImgs) {
		spr->removeFromParent();
	}
	mAllImgs.clear;	
}

void ImgAtlasNode::setString(std::string aStr)
{
	assert(!mImgMap.empty());

	clearImgs();

	std::vector<int> chCodes = split(aStr);

	for (auto chCode : chCodes) {
		auto iter = mImgMap.find(chCode);
		assert(iter != mImgMap.end());
		if (iter != mImgMap.end()) {
			auto img = iter->second;

			auto spr = CCSprite::createWithSpriteFrameName(img.c_str());
			addChild(spr);
			mAllImgs.push_back(spr);
		}
	}
}

void ImgAtlasNode::spreadImgs()
{
	std::vector<CCSize> lAllSizes;
	auto lTotalWidth = 0.f;
	for (auto spr : mAllImgs)
	{
		auto size = spr->getContentSize();// * spr->getScale();
		lAllSizes.push_back(size);

		lTotalWidth += size.width;
	}

	auto lOrigin = -lTotalWidth/2;
	auto lIdx = 0;
	for (auto spr : mAllImgs)
	{
		auto lShift = lAllSizes[lIdx++].width/2;
		spr->setPosition(ccp(lOrigin + lShift, 0));
		lOrigin += lShift;
	}
}