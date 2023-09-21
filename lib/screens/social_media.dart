import 'package:flutter/material.dart';



class StoryBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StoryBoard'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action here
            },
          ),
          
        ],
      ),
      body: ListView(
        children: [
          _buildStatusUpdate(),
          _buildPosts(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle create post action here
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusUpdate() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.0,
              backgroundImage: AssetImage('assets/images/profile_pic.jpg'),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                style: TextStyle(fontSize: 18.0, color: Colors.black),
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosts() {
    return Column(
      children: [
        _buildPost('Shihan', 'assets/images/post_image_1.jpg', 'Horror Story 😃'),
        _buildPost('Saiful', 'assets/images/post_image_2.jpg', 'Romantic Story🌴🌞'),
        // Add more posts here
      ],
    );
  }

  Widget _buildPost(String username, String imageAsset, String postText) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24.0,
              backgroundImage: AssetImage('assets/images/profile_pic.jpg'),
            ),
            title: Text(username),
            subtitle: Text('2 hours ago'),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                // Handle more options action here
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(postText),
          ),
          // Image.asset(
          //   imageAsset,
          //   fit: BoxFit.cover,
          // ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: () {
                    // Handle like action here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    // Handle comment action here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    // Handle share action here
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
