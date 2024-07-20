using OpenCvSharp;

namespace scancrops_FA {
    public partial class Form1 : Form {
        public Form1() {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e) {
            using Mat mat_tmp = new("testimage/image01.png");
            Cv2.ImShow("sample", mat_tmp);
        }
    }
}
