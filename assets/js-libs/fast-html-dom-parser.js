JSON.safeStringify = (obj, indent = 2) => {
    let cache = [];
    const retVal = JSON.stringify(
        obj,
        (key, value) =>
        typeof value === "object" && value !== null
            ? cache.includes(value)
            ? undefined 
            : cache.push(value) && value 
            : value,
        indent
    );
    cache = null;
    return retVal;
};

class HTMLElementParser{
    constructor(json){
        this.parentNode = json.parentNode;
        this.element = json.element;
        this.tag = json.tag;
        this.attributes = json.attributes;
        this.childNodes = json.childNodes;
        this.innerHTML = json.innerHTML;

        //Other parameters
        this.nodeName = this.tag.toUpperCase();
    }

    toJson(){
        return JSON.safeStringify(this);
    }

    /*
    * PRIVATE
    */
    setLastAttr(){
        this.firstChild = this.childNodes.length > 0 ? this.childNodes[0] : false;
        this.lastChild = this.childNodes.length > 0 ? this.childNodes[this.childNodes.length-1] : false;

        //innerHTML
        const fermeture = `</${this.tag}>`;
        let count = 0;
        this.childNodes.forEach((child) => {
            if(child.tag == this.tag) count++;
        });
        const fermetureIndex = this.innerHTML.indexOf(fermeture, count);
        if(fermetureIndex != -1){
            this.innerHTML = this.innerHTML.substring(0, fermetureIndex);
        }

        //outerHTML and textContent
        this.outerHTML = this.element + this.innerHTML + fermeture;
        this.textContent = this.innerHTML.replace(/<\/?[a-z]+[^>]*>/gi, '');
    }

    /*
    * METHODS
    */
    getAttribute(name){
        const f = this.attributes.filter(e => e.name == name);
        return f.length > 0 ? f[0].value : false;
    }

    setAttribute(name, value){
        const f = this.attributes.filter(e => e.name == name);
        if(f.length > 0) f[0].value = value;
    }

    /*
    * GETTERS
    */
    getElementById(id){
        let res = false;
        this.childNodes.forEach((e) => {
            const f = e.attributes.filter(a => a.name == "id" && a.value == id);
            if(f.length > 0) res = e;
            if(e.childNodes.length > 0 && !res) res = e.getElementById(id);
        })
        return res;
    }

    getElementsByClassName(className){
        let res = [];
        this.childNodes.forEach((e) => {
            const f = e.attributes.filter(a => a.name == "class" && a.value.split(' ').indexOf(className) != -1);
            if(f.length > 0) res.push(e);
            if(e.childNodes.length > 0) res = res.concat(e.getElementsByClassName(className));
        })
        return res;
   }

   getElementsByTagName(tagName){
        let res = [];
        this.childNodes.forEach((e) => {
            if(e.tag == tagName) res.push(e);
            if(e.childNodes.length > 0) res = res.concat(e.getElementsByTagName(tagName));
        })
        return res;
    }

    getElementsByName(name){
        let res = [];
        this.childNodes.forEach((e) => {
            const f = e.attributes.filter(a => a.name == "name" && a.value == name);
            if(f.length > 0) res.push(e);
            if(e.childNodes.length > 0) res = res.concat(e.getElementsByName(name));
        })
        return res;
    }
}

class FastHTMLParser{
    /*
    * CONSTRUCTOR
    */
    constructor(html){
        //Remove useless from the code
        html = this.removeComments(html);

        const tags = html.match(/<\/?[a-z]+[^>]*>/gi);
        const tree = [];
    
        let parents = [];
        const all = [];
    
        tags.forEach(element => {
            if(!element.includes('</')){
                //PARSE HTML
                const parse = element.match(/[a-z-_\d]+(="[^"]*")?(='[^']*')?/gi);
    
                //TAG
                const tag = parse.shift();
    
                //ATTRIBUTES
                const attributes = [];
                parse.forEach((attr) => {
                    const separator = attr.split('=');
                    const name = separator.shift();
                    attributes.push({
                        name: name,
                        value: separator.length > 0 ? separator.join('=').replace(/"|'/gi, "") : false
                    });
                });
    
                //PARENT
                let parent = parents.length > 0 ?  parents[parents.length-1] : false;
    
                //innerHTML
                html = html.substring(html.indexOf(element)+element.length);

                //CONTRUCTION
                const res = new HTMLElementParser({
                    parentNode: parent,
                    element: element,
                    tag: tag,
                    attributes: attributes,
                    childNodes: [],
                    innerHTML: html
                })
    
                //childNodes OR ADD TREE
                if(parent !== false){
                    parents[parents.length-1].childNodes.push(res);
                } else {
                    tree.push(res);
                }

                all.push(res);
    
                //Push to parent if not closed
                if(!element.includes("/>") && ![
                    'area',
                    'base',
                    'br',
                    'col',
                    'embed',
                    'hr',
                    'img',
                    'input',
                    'link',
                    'meta',
                    'param',
                    'source',
                    'track',
                    'wbr',
                    'command',
                    'keygen',
                    'menuitem'
                ].includes(tag)) parents.push(res);
            } else {
                parents.pop();
            }
        });
    
        //Final
        all.forEach((e) => {
            e.setLastAttr();
        })

        this.tree = tree;
    }

    removeComments(html){
        return html.replace(/<![\s\S]+?>/gi, '');
    }

    toJson(){
        return JSON.safeStringify(this.tree);
    }

    /*
    * Methods
    */
   getElementById(id){
        let res = false;
        this.tree.forEach((e) => {
            const f = e.attributes.filter(a => a.name == "id" && a.value == id);
            if(f.length > 0) res = e;
            if(e.childNodes.length > 0 && !res) res = e.getElementById(id);
        })
        return res;
   }

   getElementsByClassName(className){
        let res = [];
        this.tree.forEach((e) => {
            const f = e.attributes.filter(a => a.name == "class" && a.value.split(' ').indexOf(className) != -1);
            if(f.length > 0) res.push(e);
            if(e.childNodes.length > 0) res = res.concat(e.getElementsByClassName(className));
        })
        return res;
   }

   getElementsByTagName(tagName){
        let res = [];
        this.tree.forEach((e) => {
            if(e.tag == tagName) res.push(e);
            if(e.childNodes.length > 0) res = res.concat(e.getElementsByTagName(tagName));
        })
        return res;
    }

    getElementsByName(name){
        let res = [];
        this.tree.forEach((e) => {
            const f = e.attributes.filter(a => a.name == "name" && a.value == name);
            if(f.length > 0) res.push(e);
            if(e.childNodes.length > 0) res = res.concat(e.getElementsByName(name));
        })
        return res;
    }
}
