import SwiftUI

struct FileChangesView: View {
    @ObservedObject var vm: FileChangesViewModel
    
    var body: some View {
        VStack {
            if (vm.isLoading) {
                Text("Loading…")
            } else {
                ScrollView {
                    ForEach(Array(vm.changes.enumerated()), id: \.offset) { _, change in
                        Text(change)
                        Divider()
                    }.font(.body.monospaced())
                }
            }
        }
        .onAppear { vm.loadChanges() }
        .padding()
        .navigationTitle("File: \(vm.changedFile.fileURL.relativePath)")
    }
    
    private func createUnsettableBinding(_ s: String) -> Binding<String> {
        return Binding(get: { s }, set: { _ in /* do nothing */})
    }
}
    
//    struct FileChangesView_Previews: PreviewProvider {
//        static var previews: some View {
//            NavigationView {
//                FileChangesView(vm: FileChangesViewModel(fileURL: URL(filePath: "test.txt"), changes: [
//"""
//index 8ab7f42..f282fcf 100644
//--- a/src/string_operations.c
//+++ b/src/string_operations.c
//@@ -1,5 +1,16 @@
//#include <stdio.h>
//+char *my_strcat(char *t, char *s)
//diff --git a/src/string_operations.c b/src/string_operations.c
//index 8ab7f42..f282fcf 100644
//--- a/src/string_operations.c
//+++ b/src/string_operations.c
//@@ -1,5 +1,16 @@
//#include <stdio.h>
//+char *my_strcat(char *t, char *s)
//+
//{
//   +
//   char *p = t;
//   +
//   +
//   +
//   while (*p)
//   ++p;
//   +
//   while (*p++ = *s++)
//   + ;
//   + return t;
//   +
//}
//+
//size_t my_strlen(const char *s)
//{
//   const char *p = s;
//   @@ -23,6 +34,7 @@ int main(void)
//   {
//"""
//                ]))
//            }
//        }
//    }
