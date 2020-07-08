//
//  NetUtils.cpp
//  test2
//
//  Created by user on 5/12/20.
//  Copyright © 2020 user. All rights reserved.
//
#include <iostream>
#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>
#include <boost/asio/connect.hpp>
#include <boost/asio/buffer.hpp>
#include <boost/asio/ip/tcp.hpp>
#include <cstdlib>
#include <string>

#include "NetUtils.hpp"

namespace beast = boost::beast;     // from <boost/beast.hpp>
namespace http = beast::http;       // from <boost/beast/http.hpp>
namespace net = boost::asio;        // from <boost/asio.hpp>
using tcp = net::ip::tcp;           // from <boost/asio/ip/tcp.hpp>

using namespace std;

#define HOST "google.com"
#define PORT 80

const string SERVER_DOMAIN = "google.com";

bool serverIsAvailable(){
    try
    {
        // Check command line arguments.
        auto const host = "192.168.0.107";
        auto const port = "8080";
        auto const target = "/api/defect/22";
        int version = 10;
        
        // The io_context is required for all I/O
        net::io_context ioc;
        
        // These objects perform our I/O
        tcp::resolver resolver(ioc);
        beast::tcp_stream stream(ioc);
        
        // Look up the domain name
        auto const results = resolver.resolve(host, port);
        
        // Make the connection on the IP address we get from a lookup
        stream.connect(results);
        
        // Set up an HTTP GET request message
        http::request<http::string_body> req{http::verb::get, target, version};
        req.set(http::field::host, host);
        req.set(http::field::user_agent, BOOST_BEAST_VERSION_STRING);
        
        // Send the HTTP request to the remote host
        http::write(stream, req);
        
        // This buffer is used for reading and must be persisted
        beast::flat_buffer buffer;
        
        // Declare a container to hold the response
        http::response<http::string_body> res;
        
        // Receive the HTTP response
        http::read(stream, buffer, res);
        
        // Write the message to standard out
        std::cout << res.body().data() << std::endl;
        
        // Gracefully close the socket
        beast::error_code ec;
        stream.socket().shutdown(tcp::socket::shutdown_both, ec);
        
        // not_connected happens sometimes
        // so don't bother reporting it.
        //
        if(ec && ec != beast::errc::not_connected)
            throw beast::system_error{ec};
        
        // If we get here then the connection is closed gracefully
    }
    catch(std::exception const& e)
    {
        std::cerr << "Error: " << e.what() << std::endl;
    }
    return false;
}
