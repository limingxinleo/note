const Proxy = require('static-web-proxy')
const crypto = require('crypto')
const path = require('path')
const proxy = new Proxy({
    proxy: {
        host: process.env.PROXY_HOST,
        port: process.env.PROXY_PORT,
        path: '/api',
        auth: (req, res) => {
            const date = new Date().toUTCString()
            const username = 'username'
            const secret = 'secret'
            const sign = _sign(date, secret, req.method, req.path)
            const Authorization = `hmac username="${username}",algorithm="hmac-sha256",headers="x-date request-line",signature="${sign}"`
            req.setHeader('X-Date', date)
            req.setHeader('Authorization', Authorization)
        }
    },
    web: {
        dir: path.join(__dirname, '/dist')
    },
})

const _sign = (date, secret, method, path) => {
    const signStr = `x-date: ${date}\n${method} ${path} HTTP/1.1`
    return crypto.createHmac('sha256', secret).update(signStr).digest('base64')
}
proxy.start()