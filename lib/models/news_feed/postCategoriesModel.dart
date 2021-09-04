import 'dart:collection';

enum PostCategories {article, meme, selfie, art, general}

class PostCategoriesModel {

  PostCategories _postCategories = PostCategories.general;
  PostCategories get postCategories => _postCategories;

  Queue<PostCategories> files = Queue();
  Queue<PostCategories> postModelList = Queue();

  Queue<PostCategories> postToBeShownNowRef = Queue();
  Queue<PostCategories> postToBeShownLater = Queue();

  PostCategories lastReceivedDoc;

}
