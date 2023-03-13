/*    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;
      print("deepLink-----" + deepLink.toString());
      String carnivalId = deepLink?.queryParameters["CarnivalId"] ?? '';
      String continent = deepLink?.queryParameters["Continent"] ?? '';
      String blogId = deepLink?.queryParameters["blogId"] ?? '';
      String type = deepLink?.queryParameters["type"] ?? '';

      if (deepLink != null) {
        if (type == "blog") {
          _commonHelper?.startActivity(HomeActivity(currentIndex: 4, screenOpenedFromDynamicLink: true, blogShareId: blogId,));
        } else {
          _openChatAdminPage(carnivalId, continent);
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });*/

/*  BottomNavigationBarItem(
                activeIcon: Container(
                    child: SvgPicture.asset('assets/images/highlighted_meetup.svg')),
                icon: Container(
                  height: 24,
                  width: 24,
                  child: SvgPicture.asset('assets/images/Meetup.svg'),
                ),
                label: 'Meetup'),*/
