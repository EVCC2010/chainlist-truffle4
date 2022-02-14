rsync -r src/ docs/
rsync build/contracts/ChainList.json docs/
git add .
git commit -m "adding frontend files to Github pages"
git remote add origin https://evcc2010.github.io/chainlist-truffle4/
git push
