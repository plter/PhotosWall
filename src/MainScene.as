package {
    import com.plter.two.anim.AnimSet;
    import com.plter.two.anim.PropertyAnim;
    import com.plter.two.app.Context;
    import com.plter.two.display.Loader;
    import com.plter.two.display.Scene;
    import com.plter.two.net.Connection;
    import com.plter.two.net.ConnectionEvent;

    public class MainScene extends Scene {

        private var loaders:Array = [];
        private var currentLoaderIndex:uint = 0;
        private var animRunning:Boolean = false;

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
            var len:int = photos.length;
            for (var index:int = 0; index < len; index++) {
                var photoName:String = photos[index];
                var l:Loader = new Loader(context);
                l.load("/res/" + photoName);
                loaders.push(l);
                l.z = 10000;
                addChild(l);
                l['index'] = index;
            }
        }

        private function getLeftPositionAtIndex(index:int):* {
            return {'z': -5, 'x': index * 0.2 - 4, 'rotationY': Math.PI / 2};
        }

        private function getRightPositionAtIndex(index:int):* {
            return {'z': -5, 'x': 4 - (loaders.length - index - 1) * 0.2, 'rotationY': -Math.PI / 2};
        }

        private function getFoucsPosition():* {
            return {'z': -2.3, 'x': 0, 'rotationY': 0};
        }

        private function showLoader(index:int):void {
            var i:int = 0;
            var l:Loader;
            var p:*;
            for (i = 0; i < index; i++) {
                l = loaders[i];
                p = getLeftPositionAtIndex(i);
                l.z = p['z'];
                l.x = p['x'];
                l.rotationY = p['rotationY'];
            }
            l = loaders[index];
            p = getFoucsPosition();
            l.z = p['z'];
            l.x = p['x'];
            l.rotationY = p['rotationY'];
            for (i = index + 1; i < loaders.length; i++) {
                l = loaders[i];
                p = getRightPositionAtIndex(i);
                l.z = p['z'];
                l.x = p['x'];
                l.rotationY = p['rotationY'];
            }
            currentLoaderIndex = index;
        }


        private function moveObjectToTargetPosition(obj:Loader, targetPosition:*, completeHandler:Function = null):void {
            var animFrames:int = 20;
            new AnimSet(completeHandler, new PropertyAnim(this, obj, 'x', obj.x, targetPosition['x'], animFrames), new PropertyAnim(this, obj, 'z', obj.z, targetPosition['z'], animFrames), new PropertyAnim(this, obj, 'rotationY', obj.rotationY, targetPosition['rotationY'], animFrames)).together();
        }

        private function moveToIndex(targetIndex:int):void {
            function next():void {
                if (currentLoaderIndex >= targetIndex) {
                    animRunning = false;
                    return;
                }
                moveObjectToTargetPosition(loaders[currentLoaderIndex], getLeftPositionAtIndex(currentLoaderIndex));
                currentLoaderIndex++;
                moveObjectToTargetPosition(loaders[currentLoaderIndex], getFoucsPosition(), next);
            }

            function prev():void {
                if (currentLoaderIndex <= targetIndex) {
                    animRunning = false;
                    return;
                }
                moveObjectToTargetPosition(loaders[currentLoaderIndex], getRightPositionAtIndex(currentLoaderIndex));
                currentLoaderIndex--;
                moveObjectToTargetPosition(loaders[currentLoaderIndex], getFoucsPosition(), prev);
            }

            if (targetIndex > currentLoaderIndex) {
                animRunning = true;
                next();
            }
            if (targetIndex < currentLoaderIndex) {
                animRunning = true;
                prev();
            }
        }

        override public function onClick(eventType:String, x:Number, y:Number, e:MouseEvent):void {

            if (animRunning) {
                return;
            }

            var objects:Array = getObjectsAtPoint(x, y);
            if (objects.length) {
                var clickedItem:Loader = objects[0];
                var clickedIndex:int = clickedItem['index'];
                moveToIndex(clickedIndex);
            }
        }
    }
}
