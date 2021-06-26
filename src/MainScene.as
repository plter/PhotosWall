package {
    import com.plter.two.display.Scene;
    import com.plter.two.app.Context;
    import com.plter.two.display.Loader;
    import com.plter.two.net.Connection;
    import com.plter.two.net.ConnectionEvent;

    public class MainScene extends Scene {

        private var loaders:Array = [];
        private var currentLoaderIndex:uint = 0;

        public function MainScene(context:Context) {
            super(context);

            loadMeta();
        }

        private function loadMeta():void {
            new Connection().send("/res/meta.txt").onSuccess(function(event:ConnectionEvent, conn:Connection):void {
                var photos:Array = (event.data as String).split("\n");
                createPhotoLoaders(photos);
                showLoader(Math.floor(loaders.length / 2));
            });
        }

        private function createPhotoLoaders(photos:Array):void {
            for (var key:String in photos) {
                var element:Object = photos[key];
                var l:Loader = new Loader(context);
                l.load("/res/" + element);
                loaders.push(l);
                l.z = 10000;
                addChild(l);
            }
        }

        private function showLoader(index:int):void {
            var i:int = 0;
            var l:Loader;
            for (i = 0; i < index; i++) {
                l = loaders[i];
                l.z = -5;
                l.x = i * 0.2 - 4;
                l.rotationY = Math.PI / 2;
            }
            l = loaders[index];
            l.z = -2.5;
            l.x = 0;
            l.rotationY = 0;
            for (i = index + 1; i < loaders.length; i++) {
                l = loaders[i];
                l.z = -5;
                l.x = 4 - (loaders.length - i - 1) * 0.2;
                l.rotationY = Math.PI / 2;
            }
            currentLoaderIndex = index;
        }

        override public function onClick(eventType:String, x:Number, y:Number, e:MouseEvent):void {
            var len:int = loaders.length;

            var clickedIndex:int = -1;
            var index:int = 0;
            var element:Loader;
            for (index = currentLoaderIndex + 1; index < len; index++) {
                element = loaders[index];
                if (element.hitTestPoint(x, y)) {
                    clickedIndex = index;
                    break;
                }
            }
            if (clickedIndex < 0) {
                for (index = currentLoaderIndex - 1; index >= 0; index--) {
                    element = loaders[index];
                    if (element.hitTestPoint(x, y)) {
                        clickedIndex = index;
                        break;
                    }
                }
            }
            if (clickedIndex > -1) {
                showLoader(clickedIndex);
            }
        }
    }
}
