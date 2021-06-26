package {
    import com.plter.two.app.Two;

    public class Main extends Two {


        public function Main() {
            super(1000, 600, 60);

            presentScene(new MainScene(this));
            document.body.appendChild(domElement);
        }
    }
}
