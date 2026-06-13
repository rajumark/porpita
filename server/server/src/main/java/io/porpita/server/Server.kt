package io.porpita.server

import android.net.LocalServerSocket
import android.util.Log
import java.util.concurrent.Executors

class Server {
    companion object {
        private const val TAG = "Porpita.Server"
        private const val SOCKET_NAME = "porpita"

        @JvmStatic
        fun main(args: Array<String>) {
            try {
                Server().start()
            } catch (e: Exception) {
                Log.e(TAG, "Fail to start server", e)
            }
        }
    }

    private val executor = Executors.newCachedThreadPool()

    fun start() {
        Log.i(TAG, "Start server")

        val server = LocalServerSocket(SOCKET_NAME)
        Log.i(TAG, "Server started, listening on ${server.localSocketAddress}")

        while (true) {
            val conn = Connection(server.accept())
            Log.i(TAG, "Client connected")
            executor.submit(conn)
        }
    }
}